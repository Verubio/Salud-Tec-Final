from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import mysql.connector
from datetime import datetime
import os
from google import genai  # <--- Fíjate que el import también cambió un poquito

app = FastAPI()

# --- CONFIGURACIÓN DE GEMINI ---
# Aquí inicializamos el cliente con tu llave directamente para asegurar la prueba
client = genai.Client(api_key="AIzaSyA1nlKWL9dUgcvI1vBWHmkzr3sstB-rJZM")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'PeyPerritu1*', 
    'database': 'nexus4_db'
}

# --- MODELOS DE DATOS ---

class LoginRequest(BaseModel):
    correo: str
    password: str  # <--- ACTUALIZADO: Ahora el backend pide contraseña

class UserRegister(BaseModel):
    nombre_completo: str
    correo: str
    password: str
    carrera: str

class RegistroRequest(BaseModel):
    id_usuario: int
    emocion: str
    detalle: str 
    puntuacion_riesgo: float

# --- ENDPOINTS ---

@app.post("/login")
def login(request: LoginRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # RIGOR DE SEGURIDAD (7.2): Validamos correo Y contraseña
        query = "SELECT id_usuario, nombre_completo FROM Usuario WHERE correo_institucional = %s AND password_hash = %s"
        cursor.execute(query, (request.correo, request.password))
        user = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        if user:
            return {"status": "success", "user": user}
        else:
            raise HTTPException(status_code=401, detail="Credenciales incorrectas")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/register")
def register(user: UserRegister):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        # Eliminamos la coma extra y mantenemos tu orden preferido
        query = """INSERT INTO Usuario (nombre_completo, correo_institucional, password_hash, rol, carrera) 
                   VALUES (%s, %s, %s, 'Alumno', %s)"""
        
        # IMPORTANTE: El orden aquí debe ser el mismo que en los paréntesis de arriba
        valores = (user.nombre_completo, user.correo, user.password, user.carrera)
        
        cursor.execute(query, valores)
        conn.commit()
        
        cursor.close()
        conn.close()
        return {"status": "success", "message": "Usuario creado correctamente"}
    except Exception as e:
        print(f"DEBUG ERROR REGISTRO: {e}") # Mira esto en tu terminal
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/registro_animo")
def registrar_animo(request: RegistroRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        query = "INSERT INTO RegistroAnimo (id_usuario, emocion, puntuacion_riesgo, detalle) VALUES (%s, %s, %s, %s)"
        riesgo_calculado = 0.9 if request.emocion == 'Crisis' else 0.1
        
        cursor.execute(query, (request.id_usuario, request.emocion, riesgo_calculado, request.detalle))
        
        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "success", "message": "Animo guardado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/historial_animo/{id_usuario}")
def obtener_historial(id_usuario: int):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # CORRECCIÓN DE RIGOR: Añadimos 'detalle' al SELECT para que el popup de Flutter funcione
        # Quitamos el LIMIT 7 para que la matriz semanal pueda mostrar múltiples registros por día (Criterio 7.1)
        query = """SELECT emocion, fecha_hora, detalle 
                   FROM RegistroAnimo 
                   WHERE id_usuario = %s 
                   AND fecha_hora >= DATE_SUB(NOW(), INTERVAL 7 DAY)
                   ORDER BY fecha_hora DESC"""
        
        cursor.execute(query, (id_usuario,))
        registros = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        for r in registros:
            r['fecha_hora'] = r['fecha_hora'].strftime("%Y-%m-%d %H:%M:%S")
            
        return registros
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



# --- LÓGICA DEL NEXUSBOT ---

SYSTEM_PROMPT = """
Eres NexusBot, un asistente emocional para estudiantes universitarios.

Tu objetivo:
- Brindar apoyo emocional breve, claro y empático.
- Ayudar con estrés académico, ansiedad leve y motivación.

Reglas estrictas:
- NO des diagnósticos médicos o psicológicos.
- NO des instrucciones clínicas.
- NO sugieras medicamentos.
- NO reemplazas a un profesional.

Estilo:
- Responde en máximo 2-3 líneas.
- Usa lenguaje cálido, cercano y sencillo.
- Sé empático, como un amigo que escucha.

Contexto:
El usuario presenta: {contexto}

Instrucciones:
- Da un consejo práctico y sencillo.
- Puedes sugerir respiración, pausas, organización o hablar con alguien.
- No repitas exactamente la misma respuesta siempre.
"""

PALABRAS_CRISIS = [
    "no puedo más", "quiero morir", "suicidio", "ya no quiero vivir", 
    "terminar con todo", "me quiero matar", "crisis"
]

def detectar_crisis(mensaje: str) -> bool:
    mensaje = mensaje.lower()
    return any(p in mensaje for p in PALABRAS_CRISIS)

def detectar_contexto(mensaje: str) -> str:
    mensaje = mensaje.lower()
    if any(p in mensaje for p in ["examen", "tarea", "proyecto", "escuela", "compilador", "semestre"]):
        return "estrés académico"
    if any(p in mensaje for p in ["ansiedad", "nervioso", "preocupado"]):
        return "ansiedad leve"
    if any(p in mensaje for p in ["triste", "desanimado", "solo"]):
        return "tristeza"
    return "apoyo emocional general"

class ChatRequest(BaseModel):
    id_usuario: int
    mensaje: str

@app.post("/chatbot")
async def chatbot(request: ChatRequest):
    try:
        mensaje = request.mensaje

        # 🚨 FILTRO 1: CRISIS (Se responde sin gastar tokens de la IA)
        if detectar_crisis(mensaje):
            return {
                "reply": "Lo que estás sintiendo es importante 💙 No estás solo/a. Te recomiendo hablar con un profesional o alguien de confianza lo antes posible. Si puedes, busca apoyo ahora mismo."
            }

        # 🧠 FILTRO 2: CONTEXTO
        contexto = detectar_contexto(mensaje)

  # 🤖 FILTRO 3: GEMINI
        prompt_final = SYSTEM_PROMPT.format(contexto=contexto) + f"\nUsuario: {mensaje}"
        
       
        response = client.models.generate_content(
            model='gemini-2.0-flash', 
            contents=prompt_final
        )

        return {"reply": response.text}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        print(f"🔥 ERROR DEL BOT: {e}") # <--- Agrega esta línea
        raise HTTPException(status_code=500, detail=str(e))
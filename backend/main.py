from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import mysql.connector
from datetime import datetime
from dotenv import load_dotenv
import os
from google import genai  # <--- Fíjate que el import también cambió un poquito
import re
import json
from passlib.context import CryptContext


# Configuración del encriptador (Bcrypt)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Función para encriptar
def obtener_hash_password(password: str):
    return pwd_context.hash(password)

# Función para verificar
def verificar_password(plain_password: str, hashed_password: str):
    return pwd_context.verify(plain_password, hashed_password)

app = FastAPI()

# --- CONFIGURACIÓN DE GEMINI ---
# Carga las variables del archivo .env a la memoria
load_dotenv() 

# Extrae la llave de la memoria de forma segura
api_key = os.getenv("GEMINI_API_KEY")

# Inicia el cliente sin quemar la llave en el código
client = genai.Client(api_key=api_key)

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
    'password': 'Luis2911', 
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

    # --- MODELOS PARA EL CHAT ---
class InicioChatRequest(BaseModel):
    id_alumno: int
    id_psicologo: int

class MensajeRequest(BaseModel):
    id_sesion: int
    id_usuario_emisor: int
    mensaje: str

class EstadoDisponibilidadRequest(BaseModel):
    id_psicologo: int
    esta_disponible: bool

    # 1. El Modelo de Validación
class FinalizarSesionRequest(BaseModel):
    id_sesion: int

# --- ENDPOINTS ---

@app.post("/login")
def login(request: LoginRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # 1. Buscamos SOLO por correo
        query = "SELECT id_usuario, nombre_completo, rol, esta_disponible, password_hash FROM Usuario WHERE correo_institucional = %s"
        cursor.execute(query, (request.correo,))
        user = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        # 2. Verificamos que el usuario exista y que la contraseña coincida con el hash
        if not user or not verificar_password(request.password, user['password_hash']):
            raise HTTPException(status_code=401, detail="Credenciales incorrectas")
            
        # Si sobrevive la validación, le damos acceso (no devuelvas el hash al celular)
        return {
            "status": "success", 
            "user": {
                "id_usuario": user['id_usuario'], 
                "nombre_completo": user['nombre_completo'], 
                "rol": user['rol'], 
                "esta_disponible": user['esta_disponible']
            }
        }
            
    except Exception as e:
        print(f"DEBUG ERROR LOGIN: {e}") # Esto imprimirá el error real en tu consola
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/register")
def register(user: UserRegister):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        # RIGOR DE SEGURIDAD: Encriptamos la contraseña antes de tocar la BD
        password_encriptada = obtener_hash_password(user.password)
        
        query = """INSERT INTO Usuario (nombre_completo, correo_institucional, password_hash, rol, carrera) 
                   VALUES (%s, %s, %s, 'Alumno', %s)"""
        
        # Reemplazamos user.password por la variable encriptada
        valores = (user.nombre_completo, user.correo, password_encriptada, user.carrera)
        
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




# 🧠 PROMPT OPTIMIZADO
SYSTEM_PROMPT = """
Eres NexusBot, un asistente emocional para estudiantes universitarios.

Tu función es actuar como un sistema de TRIAGE emocional automatizado.

--- MEMORIA Y CONTEXTO ---
Se te proporcionará un "HISTORIAL RECIENTE". Debes usar esta información para recordar
detalles del usuario (nombres, mascotas, situaciones pasadas) y mantener una conversación fluida 
y coherente. Si el usuario hace referencia a algo que te dijo antes, usa el historial para 
responderle de forma natural, sin decir "como soy una IA no tengo acceso".

--- REGLAS DE CONTEXTO Y MEMORIA (ESTRICTO) ---
- Revisa siempre el "HISTORIAL RECIENTE". Si el usuario te pregunta por algo que él mismo mencionó en ese historial (nombres, mascotas, exámenes, tareas, objetos), ESTÁS OBLIGADO a responder usando esa información.
- ESTÁ ESTRICTAMENTE PROHIBIDO usar excusas evasivas como "no tengo acceso a tus tareas", "no puedo recordar detalles" o "como asistente emocional no sé eso".
- Si la información está en el historial, actúa como un amigo con buena memoria y respóndele de forma natural.
- (Nota: Si te pregunta por algo que de verdad NO está en el historial reciente, dile amablemente que lo olvidaste o que te lo recuerde).

--- FORMATO DE RESPUESTA OBLIGATORIO ---
Debes responder ÚNICAMENTE con un objeto JSON válido, sin texto adicional, sin Markdown.

Estructura EXACTA:
{
  "nivel_riesgo": "Bajo | Medio | Alto | Critico",
  "indicadores_detectados": ["lista corta de indicadores"],
  "respuesta": "mensaje empático breve (máximo 3 líneas)"
}

--- REGLAS CRÍTICAS ---
- NO incluyas texto fuera del JSON
- NO inventes diagnósticos clínicos
- NO uses lenguaje médico complejo
- Máximo 3 indicadores

--- CRITERIOS DE CLASIFICACIÓN ---
Bajo: Estrés académico normal
Medio: Ansiedad leve, tristeza
Alto: Desesperanza, vacío, pérdida de sentido
Critico: Intención directa de autolesión

--- RESPUESTA ---
- Sé cálido y humano
- Si es Alto o Critico, sugiere buscar ayuda real
"""

# 🛡️ REGEX MEJORADO
PATRON_CRISIS = re.compile(
    r'\b(suicid.*|matarm.*|morirm.*|ya no.*vivir|terminar.*todo)\b',
    re.IGNORECASE
)

class ChatRequest(BaseModel):
    id_usuario: int
    mensaje: str

@app.post("/chatbot")
async def chatbot(request: ChatRequest):
    try:
        mensaje = request.mensaje.strip()
        id_user = request.id_usuario
        
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        # 1. RECUPERAR HISTORIAL (Fijo y estable)
        cursor.execute("""
            SELECT rol, mensaje 
            FROM ChatBotHistorial 
            WHERE id_usuario = %s 
            ORDER BY id_mensaje DESC LIMIT 20
        """, (id_user,))
        
        historial_raw = cursor.fetchall()
        historial_raw.reverse()

        # 2. FORMATEO SEGURO (A prueba de comillas)
        texto_historial = ""
        if historial_raw:
            texto_historial = "\n--- HISTORIAL RECIENTE ---\n"
            for h in historial_raw:
                actor = "Usuario" if h['rol'] == 'user' else "NexusBot"
                texto_historial += f"{actor}: {h['mensaje']}\n"
            texto_historial += "--------------------------\n"

        respuesta_bot = ""
        nivel_riesgo = "Bajo"
        origen = ""

        # 🚨 FILTRO 1: REGEX
        if PATRON_CRISIS.search(mensaje):
            respuesta_bot = "Lo que estás sintiendo es muy importante. No estás solo. Por favor, busca apoyo profesional o habla con alguien de confianza ahora mismo."
            nivel_riesgo = "Critico"
            origen = "RegEx"
        else:
            # 🧠 FILTRO 2: IA CON MEMORIA
            prompt_final = SYSTEM_PROMPT + f"{texto_historial}\nMensaje actual del usuario:\n\"{mensaje}\""

            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt_final,
                config={"response_mime_type": "application/json"}
            )

            texto = response.text.strip()
            if texto.startswith("```"):
                texto = texto.replace("```json", "").replace("```", "").strip()

            datos_ia = json.loads(texto)

            nivel_riesgo = datos_ia.get("nivel_riesgo", "Bajo")
            respuesta_bot = datos_ia.get("respuesta", "Aquí estoy para escucharte.")
            origen = "IA"

            if nivel_riesgo not in ["Bajo", "Medio", "Alto", "Critico"]:
                nivel_riesgo = "Medio"

            # 🚨 LOG DE ALERTA
            if nivel_riesgo in ["Alto", "Critico"]:
                indicadores = datos_ia.get("indicadores_detectados", [])
                print(f"!!! ALERTA ROJA !!! Usuario: {id_user} | Riesgo: {nivel_riesgo} | Indicadores: {indicadores}")

        # 3. GUARDAR EN BD (Tu brillante aportación validada)
        cursor.execute(
            "INSERT INTO ChatBotHistorial (id_usuario, rol, mensaje, nivel_riesgo) VALUES (%s, 'user', %s, %s)",
            (id_user, mensaje, nivel_riesgo)
        )

        cursor.execute(
            "INSERT INTO ChatBotHistorial (id_usuario, rol, mensaje, nivel_riesgo) VALUES (%s, 'bot', %s, %s)",
            (id_user, respuesta_bot, nivel_riesgo)
        )

        conn.commit()
        cursor.close()
        conn.close()

        return {
            "reply": respuesta_bot,
            "riesgo_detectado": nivel_riesgo,
            "origen": origen
        }

    except json.JSONDecodeError as e:
        print(f"❌ ERROR JSON IA: {e}")
        return {"reply": "Estoy aquí para escucharte. ¿Quieres intentar decirlo de otra forma?"}

    except Exception as e:
        print(f"🔥 ERROR DEL BOT: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/psicologos_disponibles")
def obtener_psicologos():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # Solo traemos psicólogos que hayan marcado 'esta_disponible' como True
        query = """SELECT id_usuario, nombre_completo, esta_disponible 
                   FROM Usuario 
                   WHERE rol = 'Psicologo' AND esta_disponible = TRUE"""
        
        cursor.execute(query)
        psicologos = cursor.fetchall()
        
        cursor.close()
        conn.close()
        return psicologos
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    # --- ENDPOINTS DEL CHAT ---
@app.post("/chat/iniciar")
def iniciar_sesion_chat(req: InicioChatRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # 1. Buscamos si ya existe una sesión activa entre ellos
        query_sesion = """SELECT id_sesion FROM SesionChat 
                          WHERE id_alumno = %s AND id_psicologo = %s AND esta_activa = TRUE"""
        cursor.execute(query_sesion, (req.id_alumno, req.id_psicologo))
        sesion = cursor.fetchone()
        
        if not sesion:
            # RIGOR TÉCNICO: La sesión no existe. Antes de crearla, verificamos si el Doc está disponible
            query_disponibilidad = "SELECT esta_disponible FROM Usuario WHERE id_usuario = %s AND rol = 'Psicologo'"
            cursor.execute(query_disponibilidad, (req.id_psicologo,))
            psicologo = cursor.fetchone()
            
            # Si el doc no existe o su switch está en FALSE, abortamos la misión
            if not psicologo or psicologo['esta_disponible'] == 0:
                cursor.close()
                conn.close()
                raise HTTPException(status_code=400, detail="El profesional ya no se encuentra disponible.")
            
            # Si pasó el filtro de seguridad, creamos la sesión
            cursor.execute("INSERT INTO SesionChat (id_alumno, id_psicologo) VALUES (%s, %s)", 
                           (req.id_alumno, req.id_psicologo))
            conn.commit()
            id_sesion = cursor.lastrowid
        else:
            id_sesion = sesion['id_sesion']
            
        # 2. Obtenemos el historial de mensajes
        query_mensajes = """SELECT id_usuario_emisor, mensaje, fecha_hora 
                            FROM Chat WHERE id_sesion = %s ORDER BY fecha_hora ASC"""
        cursor.execute(query_mensajes, (id_sesion,))
        mensajes = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        for m in mensajes:
            m['fecha_hora'] = m['fecha_hora'].strftime("%H:%M")
            
        return {"status": "success", "id_sesion": id_sesion, "mensajes": mensajes}
    except HTTPException:
        # Dejamos pasar los errores HTTP controlados (como el 400 que acabamos de crear)
        raise
    except Exception as e:
        print(f"DEBUG ERROR CHAT: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/chat/enviar")
def enviar_mensaje(req: MensajeRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        query = """INSERT INTO Chat (id_sesion, id_usuario_emisor, mensaje) 
                   VALUES (%s, %s, %s)"""
        cursor.execute(query, (req.id_sesion, req.id_usuario_emisor, req.mensaje))
        conn.commit()
        
        cursor.close()
        conn.close()
        return {"status": "success"}
    except Exception as e:
        print(f"DEBUG ERROR ENVIAR MSJ: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@app.put("/psicologo/disponibilidad")
def actualizar_disponibilidad(req: EstadoDisponibilidadRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        # RIGOR: Ejecutamos el update sin hacer colapsar el sistema si el valor es el mismo
        query = """UPDATE Usuario 
                   SET esta_disponible = %s 
                   WHERE id_usuario = %s AND rol = 'Psicologo'"""
        
        cursor.execute(query, (req.esta_disponible, req.id_psicologo))
        conn.commit()
        
        cursor.close()
        conn.close()
        
        return {"status": "success", "mensaje": f"Disponibilidad actualizada a {req.esta_disponible}"}
    except Exception as e:
        print(f"DEBUG ERROR DISPONIBILIDAD: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/psicologo/{id_psicologo}/sesiones")
def obtener_sesiones_activas(id_psicologo: int):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # Un JOIN para traer el nombre del alumno en base a las sesiones activas
        query = """
            SELECT s.id_sesion, s.id_alumno, u.nombre_completo AS nombre_alumno, s.fecha_inicio
            FROM SesionChat s
            JOIN Usuario u ON s.id_alumno = u.id_usuario
            WHERE s.id_psicologo = %s AND s.esta_activa = TRUE
            ORDER BY s.fecha_inicio DESC
        """
        cursor.execute(query, (id_psicologo,))
        sesiones = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return {"status": "success", "sesiones": sesiones}
    except Exception as e:
        print(f"DEBUG ERROR SESIONES PSICOLOGO: {e}")
        raise HTTPException(status_code=500, detail=str(e))

    # 2. El Endpoint de Cierre
@app.put("/chat/finalizar")
def finalizar_sesion(req: FinalizarSesionRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        # Actualizamos la bandera a FALSE
        query = "UPDATE SesionChat SET esta_activa = FALSE WHERE id_sesion = %s"
        cursor.execute(query, (req.id_sesion,))
        conn.commit()
        
        # Validamos si realmente existía la sesión
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="Sesión no encontrada o ya estaba inactiva.")
            
        cursor.close()
        conn.close()
        return {"status": "success", "mensaje": "Sesión finalizada correctamente"}
    except Exception as e:
        print(f"DEBUG ERROR FINALIZAR SESION: {e}")
        raise HTTPException(status_code=500, detail=str(e))    


@app.get("/chat/{id_sesion}/sync")
def sincronizar_chat(id_sesion: int):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # 1. Revisamos el estado de la sesión
        cursor.execute("SELECT esta_activa FROM SesionChat WHERE id_sesion = %s", (id_sesion,))
        sesion = cursor.fetchone()
        
        if not sesion:
            raise HTTPException(status_code=404, detail="Sesión no existe")
            
        # 2. Traemos los mensajes
        cursor.execute("""SELECT id_usuario_emisor, mensaje, fecha_hora 
                          FROM Chat WHERE id_sesion = %s ORDER BY fecha_hora ASC""", (id_sesion,))
        mensajes = cursor.fetchall()
        
        for m in mensajes:
            m['fecha_hora'] = m['fecha_hora'].strftime("%H:%M")
            
        cursor.close()
        conn.close()
        
        return {
            "status": "success", 
            "esta_activa": sesion['esta_activa'] == 1, 
            "mensajes": mensajes
        }
    except Exception as e:

        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/chatbot/historial/{id_usuario}")
def obtener_historial_chatbot(id_usuario: int):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # Traemos los últimos 50 mensajes de la BD ordenados del más viejo al más nuevo
        cursor.execute("""
            SELECT rol, mensaje 
            FROM ChatBotHistorial 
            WHERE id_usuario = %s 
            ORDER BY id_mensaje ASC LIMIT 50
        """, (id_usuario,))
        
        historial = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return {"status": "success", "mensajes": historial}
    except Exception as e:
        print(f"DEBUG ERROR GET HISTORIAL: {e}")
        raise HTTPException(status_code=500, detail=str(e))    
    
@app.get("/psicologo/alertas_triage")
def obtener_alertas_triage():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # RIGOR CLÍNICO + TÉCNICO: 
        # - Solo alertas NO atendidas
        # - Evitamos duplicados por usuario
        # - Priorizamos el riesgo más alto con MAX
        query = """
            SELECT 
                c.id_usuario AS id_alumno, 
                u.nombre_completo, 
                MAX(c.fecha_hora) AS ultima_alerta, 
                MAX(c.nivel_riesgo) AS nivel_riesgo
            FROM ChatBotHistorial c
            JOIN Usuario u ON c.id_usuario = u.id_usuario
            WHERE c.nivel_riesgo IN ('Alto', 'Critico')
              AND c.fecha_hora >= DATE_SUB(NOW(), INTERVAL 48 HOUR)
              AND c.alerta_atendida = FALSE
            GROUP BY c.id_usuario, u.nombre_completo
            ORDER BY ultima_alerta DESC
        """
        
        cursor.execute(query)
        alertas = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        for a in alertas:
            a['ultima_alerta'] = a['ultima_alerta'].strftime("%Y-%m-%d %H:%M:%S")
            
        return {"status": "success", "alertas": alertas}
    
    except Exception as e:
        print(f"DEBUG ERROR ALERTAS TRIAGE: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@app.put("/psicologo/alerta/{id_alumno}/atender")
def atender_alerta_alumno(id_alumno: int):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        # ACTUALIZACIÓN MASIVA CONTROLADA
        query = """
            UPDATE ChatBotHistorial 
            SET alerta_atendida = TRUE 
            WHERE id_usuario = %s 
              AND nivel_riesgo IN ('Alto', 'Critico') 
              AND alerta_atendida = FALSE
        """
        
        cursor.execute(query, (id_alumno,))
        conn.commit()
        
        filas_afectadas = cursor.rowcount

        cursor.close()
        conn.close()

        # UX inteligente
        if filas_afectadas == 0:
            return {
                "status": "warning",
                "message": "No había alertas pendientes para este alumno"
            }

        return {
            "status": "success",
            "message": f"Alertas limpiadas: {filas_afectadas}"
        }

    except Exception as e:
        print(f"DEBUG ERROR ATENDER ALERTA: {e}")
        raise HTTPException(status_code=500, detail=str(e)) 
    

@app.get("/alumno/{id_alumno}/sesion_activa")
def verificar_sesion_activa_alumno(id_alumno: int):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        # 1. Buscamos si el alumno tiene un chat vivo con algún psicólogo
        cursor.execute("""
            SELECT id_sesion, id_psicologo, fecha_inicio 
            FROM SesionChat 
            WHERE id_alumno = %s AND esta_activa = TRUE 
            LIMIT 1
        """, (id_alumno,))
        sesion = cursor.fetchone()

        # Si no hay sesión, devolvemos null pacíficamente
        if not sesion:
            cursor.close()
            conn.close()
            return {"status": "success", "sesion_activa": None, "total_mensajes": 0}

        # 2. Si hay sesión, contamos los mensajes. Esto es el motor de tu punto rojo.
        cursor.execute("SELECT COUNT(*) AS total FROM Chat WHERE id_sesion = %s", (sesion['id_sesion'],))
        resultado_conteo = cursor.fetchone()
        total_mensajes = resultado_conteo['total'] if resultado_conteo else 0

        if sesion['fecha_inicio']:
            sesion['fecha_inicio'] = sesion['fecha_inicio'].strftime("%Y-%m-%d %H:%M:%S")

        cursor.close()
        conn.close()

        return {
            "status": "success",
            "sesion_activa": sesion,
            "total_mensajes": total_mensajes
        }

    except Exception as e:
        print(f"DEBUG ERROR SESION ACTIVA ALUMNO: {e}")
        raise HTTPException(status_code=500, detail=str(e))    
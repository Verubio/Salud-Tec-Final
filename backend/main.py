from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import mysql.connector

app = FastAPI()

# Configuración obligatoria para que Flutter se conecte
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuración de tu MySQL (¡CAMBIA EL PASSWORD!)
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Luis2911', 
    'database': 'nexus4_db'
}

class LoginRequest(BaseModel):
    correo: str

@app.post("/login")
def login(request: LoginRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # Validación institucional del dominio @itslp.tecnm.mx
        query = "SELECT id_usuario, nombre_completo, rol FROM Usuario WHERE correo_institucional = %s"
        cursor.execute(query, (request.correo,))
        user = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        if user:
            return {"status": "success", "user": user}
        else:
            raise HTTPException(status_code=404, detail="Usuario no encontrado en el padrón del Tec")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Iniciar con: uvicorn main:app --reload --host 0.0.0.0

class RegistroRequest(BaseModel):
    id_usuario: int
    emocion: str
    detalle: str # <--- Agrega esto si no está
    puntuacion_riesgo: float # Esto lo envía Flutter, pero tú calculas otro 'riesgo' abajo

@app.post("/registro_animo")
def registrar_animo(request: RegistroRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        # El query está bien, pero necesitamos pasarle el cuarto valor
        query = "INSERT INTO RegistroAnimo (id_usuario, emocion, puntuacion_riesgo, detalle) VALUES (%s, %s, %s, %s)"
        
        # Algoritmo de riesgo
        riesgo_calculado = 0.9 if request.emocion == 'Crisis' else 0.1
        
        # PASAMOS LOS 4 VALORES (Asegúrate de incluir request.detalle al final)
        cursor.execute(query, (request.id_usuario, request.emocion, riesgo_calculado, request.detalle))
        
        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "success", "message": "Animo guardado"}
    except Exception as e:
        print(f"ERROR REAL: {e}") # Esto te dirá el error exacto en terminal
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/historial_animo/{id_usuario}")
def obtener_historial(id_usuario: int):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        
        # Obtenemos los últimos 7 registros ordenados por fecha
        query = """SELECT emocion, fecha_hora 
                   FROM RegistroAnimo 
                   WHERE id_usuario = %s 
                   ORDER BY fecha_hora DESC LIMIT 7"""
        
        cursor.execute(query, (id_usuario,))
        registros = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        # Formateamos la fecha para que Flutter la lea fácil
        for r in registros:
            r['fecha_hora'] = r['fecha_hora'].strftime("%d/%m %H:%M")
            
        return registros
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
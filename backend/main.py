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
    detalle: str

@app.post("/registro_animo")
def registrar_animo(request: RegistroRequest):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        # Guardamos en la tabla que ya creamos en MySQL
        query = "INSERT INTO RegistroAnimo (id_usuario, emocion, puntuacion_riesgo) VALUES (%s, %s, %s)"
        
        # Algoritmo de riesgo "Express" para la Hackathon:
        # Si dice "Crisis", el riesgo es alto (0.9), si no, bajo (0.1)
        riesgo = 0.9 if request.emocion == 'Crisis' else 0.1
        
        cursor.execute(query, (request.id_usuario, request.emocion, riesgo))
        conn.commit()
        
        cursor.close()
        conn.close()
        return {"status": "success", "message": "Animo guardado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
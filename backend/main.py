from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import mysql.connector
from datetime import datetime

app = FastAPI()

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
        
        # RIGOR DE SEGURIDAD (7.2): Validamos correo Y contraseña
        query = "SELECT id_usuario, nombre_completo, rol, esta_disponible FROM Usuario WHERE correo_institucional = %s AND password_hash = %s"
        cursor.execute(query, (request.correo, request.password))
        user = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        if user:
            return {"status": "success", "user": {"id_usuario": user['id_usuario'], "nombre_completo": user['nombre_completo'], "rol": user['rol'], "esta_disponible": user['esta_disponible']}}
        else:
            raise HTTPException(status_code=401, detail="Credenciales incorrectas")
            
    except Exception as e:
        print(f"DEBUG ERROR LOGIN: {e}") # Esto imprimirá el error real en tu consola
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
            # Si no existe, creamos una nueva sesión
            cursor.execute("INSERT INTO SesionChat (id_alumno, id_psicologo) VALUES (%s, %s)", 
                           (req.id_alumno, req.id_psicologo))
            conn.commit()
            id_sesion = cursor.lastrowid
        else:
            id_sesion = sesion['id_sesion']
            
        # 2. Obtenemos el historial de mensajes de esa sesión
        query_mensajes = """SELECT id_usuario_emisor, mensaje, fecha_hora 
                            FROM Chat WHERE id_sesion = %s ORDER BY fecha_hora ASC"""
        cursor.execute(query_mensajes, (id_sesion,))
        mensajes = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        # Formatear fechas para JSON
        for m in mensajes:
            m['fecha_hora'] = m['fecha_hora'].strftime("%H:%M")
            
        return {"status": "success", "id_sesion": id_sesion, "mensajes": mensajes}
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
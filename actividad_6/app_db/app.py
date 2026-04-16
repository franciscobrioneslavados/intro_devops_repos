from flask import Flask
import socket
import os
import time
import threading
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

app = Flask(__name__)

# Configuración de la base de datos (PostgreSQL)
DB_URL = os.getenv("DATABASE_URL", "postgresql://user:pass@db:5432/logs_db")
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
Base = declarative_base()

# Modelo de la tabla de logs
class ServiceLog(Base):
    __tablename__ = 'service_logs'
    id = Column(Integer, primary_key=True)
    hostname = Column(String(100))
    message = Column(String(255))
    timestamp = Column(DateTime, default=datetime.utcnow)

# Crear tablas si no existen
Base.metadata.create_all(engine)

def background_logger():
    """Función que guarda un log cada 60 segundos"""
    while True:
        try:
            session = Session()
            new_log = ServiceLog(
                hostname=socket.gethostname(),
                message=f"Log automatizado generado desde {socket.gethostname()}"
            )
            session.add(new_log)
            session.commit()
            session.close()
            print(f"[{datetime.now()}] Log guardado en DB.")
        except Exception as e:
            print(f"Error guardando log: {e}")
        time.sleep(60)

# Iniciar el hilo de logging automático
threading.Thread(target=background_logger, daemon=True).start()

@app.route("/")
def index():
    session = Session()
    # Obtener los últimos 10 logs
    logs = session.query(ServiceLog).order_by(ServiceLog.timestamp.desc()).limit(10).all()
    session.close()

    node = os.getenv("NODE_NAME", "Desconocido")
    inst_id = os.getenv("INSTANCE_ID", "No disponible")
    az = os.getenv("AVAILABILITY_ZONE", "Desconocida")
    ip = os.getenv("PRIVATE_IP", "No disponible")

    log_html = "".join([f"<li>{log.timestamp} - {log.hostname}: {log.message}</li>" for log in logs])
    
    html = f"""
    <h3>Panel de Control - Docker Compose</h3>
    <b>Hostname:</b> {socket.gethostname()}<br/>
    <b>Nodo:</b> {node}<br/>
    <b>Instance ID:</b> {inst_id}<br/>
    <b>AZ:</b> {az}<br/>
    <b>IP Privada:</b> {ip}<br/>
    <hr>
    <b>Estado DB:</b> Conectado a PostgreSQL<br/>
    <h4>Últimos 10 Logs en DB (se genera uno cada minuto):</h4>
    <ul>{log_html}</ul>
    """
    return html

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)

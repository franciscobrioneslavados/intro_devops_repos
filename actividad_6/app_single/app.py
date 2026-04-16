from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route("/")
def hello():
    node = os.getenv("NODE_NAME", "Desconocido")
    inst_id = os.getenv("INSTANCE_ID", "No disponible")
    az = os.getenv("AVAILABILITY_ZONE", "Desconocida")
    ip = os.getenv("PRIVATE_IP", "No disponible")
    
    html = "<h3>Hola desde {node}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Instance ID:</b> {inst_id}<br/>" \
           "<b>AZ:</b> {az}<br/>" \
           "<b>IP Privada:</b> {ip}<br/>"
           
    return html.format(
        node=node, 
        hostname=socket.gethostname(),
        inst_id=inst_id,
        az=az,
        ip=ip
    )

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)

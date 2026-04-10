from flask import Flask, jsonify
from redis import Redis

app= Flask(__name__)

# Conectamos al servicio "db" que definiste en el docker-compose
# Docker se encarga de que el nombre "db" resuelva a la IP del contenedor
db = Redis(host='db', port=6379) 

@app.route("/")
def home():
    # Aumentamos el contador en Redis
    visitas = db.incr('contador') #Contador es una clave en Redis que se incrementa cada vez que se accede a la ruta "/"
    #Es como una variable que se guarda en la base de datos
    return jsonify({
        "message": "¡Hola!",
        "visitas": visitas
    })

if __name__== "__main__":
    app.run(host="0.0.0.0", port= 5000)
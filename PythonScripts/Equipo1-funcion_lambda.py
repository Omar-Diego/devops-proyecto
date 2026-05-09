import json
import random

def lambda_handler(event, context):
    #Lista de mensajes aleatorios para la empresa
    mensajes = [
        "Operacion realizada con exito",
        "Operacion fallida, intente nuevamente",
        "Servicio no disponible, intente mas tarde",
    ]
    
    #Seleccionamos uno al azar
    mensaje_seleccionado = random.choice(mensajes)
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'status': 'success',
            'message': mensaje_seleccionado,
            'service': 'Serverless-Microservice'
        })
    }
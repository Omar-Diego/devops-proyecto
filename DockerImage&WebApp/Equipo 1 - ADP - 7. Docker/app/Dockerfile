FROM python:3.9-slim AS builder
WORKDIR /app

#Etapa de Construcción (Builder)
#Instalamos todas las dependencias necesarias en un entorno virtual. 
RUN python -m venv /opt/venv
#Aseguramos que usemos el entorno virtual para instalar las dependencias
ENV PATH="/opt/venv/bin:$PATH"
#Copiamos el archivo de requerimientos y luego instalamos las dependencias dentro del entorno virtual.
COPY requirements.txt .
#Las instalamos sin cache para reducir el tamaño de la imagen final
RUN pip install --no-cache-dir -r requirements.txt

#Etapa de Ejecución (Runner)
FROM python:3.9-slim

#Se reestablece (se borra el builder en /app y se vuelve a hacer) el directorio de trabajo para la etapa final
WORKDIR /app 

#Copiamos solo el entorno virtual con las librerías instaladas desde el builder
COPY --from=builder /opt/venv /opt/venv
# Copiamos el código de la aplicación
COPY . .

# Aseguramos que usemos el entorno virtual
ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 5000

#Creamos un usuario no root y le asignamos la aplicación, lo que mejora la seguridad de la imagen final
#Porque evita que la aplicación se ejecute con privilegios de administrador, reduciendo el riesgo de vulnerabilidades.
RUN useradd -m myuser
USER myuser

CMD ["python", "app.py"]

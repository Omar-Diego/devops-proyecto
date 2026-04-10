#!/bin/bash
# Redirigir todo el output a un archivo de log y a la terminal
exec > >(tee -i Equipo1-instalacion_entorno.log)
exec 2>&1

echo "Instalando dependencias..."
sudo apt update -y
sudo apt install -y git vim docker.io python3 python3-pip
sudo systemctl enable docker
sudo systemctl start docker
echo "Todas las dependencias instaladas correctamente."

echo "Configurando tarea cron para limpieza de logs..."
cat << 'EOF' | sudo tee /usr/local/bin/limpiar_logs.sh
#!/bin/bash
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
echo "$(date '+%Y-%m-%d %H:%M:%S') - Limpieza de logs completada" >> /var/log/Equipo1-ejecucion_cron.log
EOF
sudo chmod +x /usr/local/bin/limpiar_logs.sh

echo "0 0 * * * root /usr/local/bin/limpiar_logs.sh" | sudo tee /etc/cron.d/limpiar_logs > /dev/null
echo "Tarea cron programada exitosamente."
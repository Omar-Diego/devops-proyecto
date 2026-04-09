#!/bin/bash
      echo "Instalando dependencias..."
      sudo apt update -y
      sudo apt install -y git vim docker.io python3 python3-pip
      sudo systemctl enable docker
      sudo systemctl start docker
      echo "Todas las dependencias instaladas correctamente."
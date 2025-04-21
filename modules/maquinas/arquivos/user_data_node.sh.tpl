#!/bin/bash

# Atualiza pacotes
apt-get update -y
apt-get upgrade -y

# Instala dependências do Docker
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Adiciona repositório Docker e instala
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Configura Docker para o usuário ubuntu
groupadd docker || true
usermod -aG docker ubuntu
newgrp docker

# Habilita Docker
systemctl enable docker
systemctl start docker

echo "Instalando Java"
sudo apt update
sudo apt install -y openjdk-17-jdk

echo "Adicionando repositório do Jenkins"
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update

echo "Instalando Jenkins"
sudo apt install -y jenkins

echo "Habilitando Jenkins"
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Cria o .env com variáveis do Terraform
echo "Criando arquivo .env"
cat <<EOT > /home/ubuntu/.env
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
NODE_ENV=production
EOT

chown ubuntu:ubuntu /home/ubuntu/.env
chmod 600 /home/ubuntu/.env

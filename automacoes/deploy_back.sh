#!/bin/bash

install_docker() {
    if ! [ -x "$(command -v docker)" ]; then
        echo "Docker não encontrado. Iniciando instalação..."

        sudo apt update -y && sudo apt upgrade -y

        sudo apt remove docker docker-engine docker.io containerd runc -y

        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt update -y

        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        sudo systemctl enable docker
        sudo systemctl start docker

        sudo usermod -aG docker $USER

        echo "Docker instalado com sucesso!"
        echo "Aplicando permissões temporariamente sem reiniciar..."

        sudo chmod 666 /var/run/docker.sock

        sudo ufw --force enable 
        sudo ufw allow 22
        sudo ufw allow 8080
        sudo ufw --force reload

    else
        echo "Docker já instalado."
    fi
}

install_docker

echo "Configuração do container Spring Boot para o projeto Mooca Solidária"

CONTAINER_NAME=mooca-back-prod

CONTAINER_PORT=8080

CONTAINER_IMAGE=moocasolidaria/mooca-solidaria-back:latest

USUARIO_BANCO="root"

SENHA_BANCO="urubu100"

HOST_BANCO=${1}

MYSQL_URL="jdbc:mysql://$HOST_BANCO:3306/TFG?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"

docker login -u moocasolidaria -p @MoocaDocker2024

if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
    echo "O container $CONTAINER_NAME já existe. Removendo..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

echo "Baixando a imagem do Container: ${CONTAINER_IMAGE}..."
docker pull $CONTAINER_IMAGE

echo "Iniciando o container..."
DOCKER_RUN="docker run -d -p $CONTAINER_PORT:8080 -e USUARIO_BANCO=$USUARIO_BANCO -e SENHA_BANCO=$SENHA_BANCO -e HOST_BANCO='$MYSQL_URL' --name $CONTAINER_NAME $CONTAINER_IMAGE"

echo "$DOCKER_RUN"

eval $DOCKER_RUN

echo "Container $CONTAINER_NAME iniciado com sucesso na porta $CONTAINER_PORT."
#!/bin/bash

# Atualizar pacotes
apt-get update -y

# Instalar dependências
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Adicionar chave GPG oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Adicionar repositório estável do Docker
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Instalar Docker CE
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Criar grupo docker (se não existir)
groupadd -f docker

# Adicionar usuário ubuntu ao grupo docker
usermod -aG docker ubuntu

# Configurar docker para iniciar no boot
systemctl enable docker

# Iniciar serviço docker
systemctl start docker

# Configurar permissões do socket do Docker
chown root:docker /var/run/docker.sock
chmod 660 /var/run/docker.sock

# Configurar ambiente para o usuário ubuntu
echo "export DOCKER_HOST=unix:///var/run/docker.sock" >> /home/ubuntu/.bashrc
echo "alias docker='docker -H unix:///var/run/docker.sock'" >> /home/ubuntu/.bashrc

# Reiniciar conexão do usuário para aplicar as alterações de grupo
# (Não é efetivo no user-data, mas será aplicado no próximo login)
pkill -u ubuntu || true
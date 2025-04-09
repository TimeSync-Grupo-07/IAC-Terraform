#!/bin/bash

install_nginx() {
    echo "Atualizando pacotes..."
    sudo apt update -y && sudo apt upgrade -y

    echo "Instalando NGINX..."
    sudo apt install nginx -y

    echo "NGINX instalado com sucesso."
}

configure_nginx() {
    PORT=3000
    NGINX_CONFIG="/etc/nginx/sites-available/default"

    echo "Configurando NGINX para o container Node.js na porta $PORT..."

    sudo tee $NGINX_CONFIG > /dev/null <<EOF
server {
    listen 80;
    server_name ${1};

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /api/ {
        proxy_pass http://${2}:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    # Removendo link simbólico existente antes de recriar
    if [ -L /etc/nginx/sites-enabled/default ]; then
        sudo rm /etc/nginx/sites-enabled/default
    fi

    sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

    echo "Validando configuração do NGINX..."
    sudo nginx -t

    if [ $? -eq 0 ]; then
        echo "Configuração válida."
        sudo systemctl restart nginx
        echo "NGINX reiniciado com sucesso!"
    else
        echo "Erro na configuração do NGINX."
        exit 1
    fi
}

configure_firewall() {
    echo "Configurando Firewall..."
    sudo ufw --force enable
    sudo ufw allow 'Nginx HTTP'
    sudo ufw allow 22
    sudo ufw allow 8080
    sudo ufw reload
    echo "Firewall configurado."
}

install_nginx
configure_nginx ${1} ${2}
configure_firewall

echo "NGINX configurado com sucesso!"
echo "Acesse: http://${1}"

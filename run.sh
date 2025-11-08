#!/bin/bash
set -e  # para parar em caso de erro

# ======================
# 1️⃣ Subir Infraestrutura
# ======================
cd terraform/

terraform init
terraform apply -auto-approve

# Exporta os IPs para o inventário do Ansible
terraform output -json bastion_ip > ../ansible/inventory/bastion.json
terraform output -json public_hosts > ../ansible/inventory/public_hosts.json
terraform output -json private_hosts > ../ansible/inventory/private_hosts.json


# Captura o nome do bucket da saída do Terraform
S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name_raw)

cd ../ansible/

# ======================
# 2️⃣ Gerar Inventário Dinâmico
# ======================
python3 inventory/generate_inventory.py

# ======================
# 3️⃣ Ler variáveis do .env local
# ======================
if [ -f .env ]; then
  # Lê o arquivo .env e exporta as variáveis
  export $(grep -v '^#' .env | xargs)
else
  echo "⚠️ Arquivo .env não encontrado na raiz do repositório Ansible!"
  exit 1
fi

# Certifica-se de que EMAIL_PASS foi definido
if [ -z "$EMAIL_PASS" ]; then
  echo "❌ Variável EMAIL_PASS não definida no .env!"
  exit 1
fi

# ======================
# 4️⃣ Executar Playbooks Ansible
# ======================
ansible-playbook -i aws.yml playbooks/install_docker_git.yml

ansible-playbook playbooks/data_reading.yml \
  -i aws.yml \
  --extra-vars "email_password=${EMAIL_PASS} s3_bucket_name=${S3_BUCKET_NAME}"

ansible-playbook -i aws.yml playbooks/pipelines_jenkins.yml

ansible-playbook playbooks/database.yml \
  -i aws.yml \
  --extra-vars "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} MYSQL_USER=${MYSQL_USER} MYSQL_PASSWORD=${MYSQL_PASSWORD}"

ansible-playbook playbooks/api_load_balancer.yml \
  -i aws.yml \
  --extra-vars "MYSQL_USER=${MYSQL_USER} MYSQL_PASSWORD=${MYSQL_PASSWORD}"

ansible-playbook -i aws.yml playbooks/instalar_node_exporter.yml

ansible-playbook -i aws.yml playbooks/grafana_env.yml

cd ..

cd terraform/

terraform output
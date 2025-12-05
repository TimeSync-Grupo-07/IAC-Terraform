# Automação Completa da Infraestrutura (Terraform + Ansible)

Este repositório contém toda a automação necessária para provisionar, configurar e disponibilizar a infraestrutura completa do projeto Timesync, incluindo servidores públicos, instâncias privadas, buckets S3, funções Lambda, balanceadores, aplicações e pipelines.

Ele integra Terraform (infraestrutura) + Ansible (configuração) + scripts auxiliares que automatizam o fluxo de ponta a ponta.

## Estrutura do Repositório

```bash
/chaves/                   # Chaves públicas e privadas consumidas por Terraform e Ansible
/terraform/                # Código IaC do provisionamento completo da AWS
  main.tf                  # Módulos principais
  outputs.tf               # IPs e infos exportadas para o Ansible
  /modules/
     rede/                 # VPC, sub-redes e security groups
     maquinas/             # EC2 públicas e privadas
     s3/                   # Buckets para raw/trusted/backup
     lambda_functions/     # Lógicas em Lambda
/ansible/                  # Playbooks e inventário dinâmico para configuração
  playbooks/               # Configuração de API, front, DB, Jenkis, captura, monitoramento
  inventory/               # Inventário dinâmico gerado após o Terraform
run.sh                     # Script principal: sobe infra + configura tudo
destroy.sh                 # Script para derrubar toda a infraestrutura
.gitignore
```

## Fluxo Geral de Execução

### 1. Provisionamento da Infra (Terraform)

- Criação da VPC, sub-redes públicas/privadas e security groups
- Criação das instâncias EC2:
    - Servidor web (público)
    - Captura de dados (público)
    - Monitoramento/controle (público)
        - API + DB (privado)
- Criação de chaves públicas para cada instância
- Criação dos buckets S3 (raw/trusted/backup)
- Deploy das Lambdas de ingestão e processamento

Os outputs são exportados automaticamente para o Ansible via JSON.

### 2. Geração Automática do Inventário Ansible

O script:

```bash
python3 inventory/generate_inventory.py
```

Transforma os outputs do Terraform em um inventário dinâmico (```aws.yml```), contendo hosts públicos, privados e bastion.

### 3. Execução dos Playbooks

O ```run.sh``` executa os seguintes playbooks, na ordem correta:

1. Instalação de Docker e Git
2. Configuração do container de leitura de e-mails
3. Configuração dos pipelines do Jenkins
4. Configuração do MySQL
5. Configuração da API e seu balanceamento
6. Configuração do front-end e do nginx de load balancer
7. Instalação do Node Exporter em todas as instâncias
8. Configuração de variáveis do Grafana

## Como Executar

### 1. Adicione suas chaves no diretório ```/chaves/```

As chaves **devem existir** antes de rodar o Terraform.
Exemplo:

```bash
/chaves/Key-public-servidor-web.pem
/chaves/Key-public-servidor-web.pem.pub
...
```

### 2. Configure o arquivo ```.env``` dentro da pasta ```/ansible/```

Use o ```.env.sample``` como referência:

```bash
EMAIL_PASS=...
MYSQL_ROOT_PASSWORD=...
MYSQL_USER=...
MYSQL_PASSWORD=...
```

### 3. Execute o provisionamento completo

```bash
chmod +x run.sh
./run.sh
```

A partir daqui todo o processo é automático.

## Como Destruir a Infraestrutura

```bash
chmod +x destroy.sh
./destroy.sh
```

Remove:

- Infra Terraform
- Inventários gerados
- Arquivos auxiliares

## Tecnologias Utilizadas

- Terraform (IAM, EC2, S3, VPC, Lambda)
- Ansible (Provisionamento pós-deploy)
- AWS:
    - EC2
    - S3
    - Lambda
    - VPC & SG
- Python para inventário dinâmico
- Shell scripts para orquestração

## Arquitetura Resumida

- 1 VPC / 2 Sub-redes (pública + privada)
- 3 instâncias públicas:
    - Servidor web
    - Captura de dados
    - Monitoramento & controle
- 1 instância privada: API + MySQL
- Buckets S3 (raw, trusted, backup)
- Lambdas ligadas a eventos de S3
- Load balancers de API e Front configurados via Ansible
- Monitoramento via Node Exporter
- Dashboards (Grafana) preparados com variáveis carregadas por Ansible
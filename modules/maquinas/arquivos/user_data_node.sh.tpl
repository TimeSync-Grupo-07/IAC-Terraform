#!/bin/bash

# Configuração de logs para melhor debug
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Função para verificar comandos
function check_command {
    if [ $? -ne 0 ]; then
        echo "Erro no comando: $1"
        exit 1
    fi
}

# Atualiza pacotes com tratamento de erro
echo "Atualizando pacotes..."
apt-get update -y
check_command "apt-get update"
apt-get upgrade -y
check_command "apt-get upgrade"

# Instala dependências essenciais
echo "Instalando dependências..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    netcat-openbsd \
    git \
    wget \
    unzip \
    jq
check_command "Instalação de dependências"

# Configuração do Docker
echo "Configurando Docker..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
check_command "Download chave Docker"

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
check_command "Instalação Docker"

systemctl enable docker
systemctl start docker
check_command "Inicialização Docker"

# Configura usuário e grupo Docker
groupadd docker || true
usermod -aG docker ubuntu

# Instala Java específico para Jenkins
echo "Instalando Java..."
apt update
apt install -y openjdk-17-jdk
check_command "Instalação Java"

# Configuração do Jenkins
echo "Instalando Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update
apt install -y jenkins
check_command "Instalação Jenkins"

sudo systemctl stop jenkins

usermod -aG docker jenkins

# Configuração inicial do Jenkins
mkdir -p /var/lib/jenkins/init.groovy.d

# Script de segurança inicial
cat <<EOF > /var/lib/jenkins/init.groovy.d/security.groovy
import jenkins.model.*
import hudson.security.*
import hudson.util.*
import jenkins.install.*

def instance = Jenkins.get()

// Cria usuário admin
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin', '@TimeSyncJenkins2025')
instance.setSecurityRealm(hudsonRealm)

// Configura autorização
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

// Desativa setup wizard
if (!instance.installState.isSetupComplete()) {
    instance.installState = InstallState.INITIAL_SETUP_COMPLETED
}

instance.save()
EOF

# Permissões corretas
chown -R jenkins:jenkins /var/lib/jenkins

# Inicia Jenkins
systemctl enable jenkins
systemctl start jenkins
check_command "Inicialização Jenkins"

# Aguarda Jenkins estar disponível
echo "Aguardando Jenkins iniciar..."
while ! nc -z localhost 8080; do
  sleep 5
done

# Aguarda API estar acessível
echo "Aguardando API do Jenkins..."
until curl -sSf http://localhost:8080/login 2>&1 >/dev/null; do
  sleep 5
done

# Instala plugins essenciais
echo "Instalando plugins..."
JENKINS_PLUGINS=(
    "workflow-job"
    "workflow-cps"
    "git"
    "docker-workflow"
    "pipeline-utility-steps"
    "blueocean"
)

# Baixa jenkins-cli.jar
JENKINS_URL="http://localhost:8080"
JENKINS_CLI="/tmp/jenkins-cli.jar"
JENKINS_USER="admin"
JENKINS_PASS="@TimeSyncJenkins2025"

# Tentativas para baixar o CLI
for i in {1..10}; do
    wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 \
        "$${JENKINS_URL}/jnlpJars/jenkins-cli.jar" -O $JENKINS_CLI && break
    sleep 5
done

# Instala plugins via CLI
for plugin in "$${JENKINS_PLUGINS[@]}"; do
    java -jar $JENKINS_CLI -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASS install-plugin $plugin -deploy
    check_command "Instalação plugin $plugin"
done

# Reinicia Jenkins para aplicar plugins
java -jar $JENKINS_CLI -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASS safe-restart

# Aguarda reinicialização
sleep 30
while ! nc -z localhost 8080; do
  sleep 5
done

# Cria o pipeline job
echo "Criando pipeline job..."
cat > /tmp/pipeline.xml <<'JENKINS_EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
  <description>Pipeline para buildar a imagem Docker do MySQL</description>
  <keepDependencies>false</keepDependencies>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps">
    <script><![CDATA[
pipeline {
    agent any

    environment {
        REPO_URL = "https://github.com/TimeSync-Grupo-07/Database-MySQL.git"
        MYSQL_ROOT_PASSWORD = "@TimeSyncRoot2025"
        MYSQL_DATABASE = "TimeSync"
        MYSQL_USER = "admin"
        MYSQL_PASSWORD = "@TimeSyncAdmin2025"
    }

    stages {
        stage('Clonar Repositório') {
            steps {
                checkout([$class: 'GitSCM', 
                         branches: [[name: '*/main']],
                         userRemoteConfigs: [[url: env.REPO_URL]]])
            }
        }

        stage('Build da imagem Docker MySQL') {
            steps {
                script {
                    docker.build("database-mysql-timesync", "--build-arg MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD --build-arg MYSQL_DATABASE=$MYSQL_DATABASE --build-arg MYSQL_USER=$MYSQL_USER --build-arg MYSQL_PASSWORD=$MYSQL_PASSWORD .")
                }
            }
        }
    }
}
    ]]></script>
    <sandbox>true</sandbox>
  </definition>
  <disabled>false</disabled>
</flow-definition>
JENKINS_EOF

# Cria o job
for i in {1..5}; do
    java -jar $JENKINS_CLI -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASS create-job "build-mysql-job" < /tmp/pipeline.xml && break
    sleep 10
done

echo "Configuração completa!"
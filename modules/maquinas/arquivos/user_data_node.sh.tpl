#!/bin/bash
set -e

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "========== Atualizando sistema =========="
apt-get update -y
apt-get upgrade -y

echo "========== Instalando dependências básicas =========="
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    netcat-openbsd \
    git \
    wget \
    unzip \
    jq \
    openjdk-17-jdk \
    software-properties-common

apt install -y zip python3 python3-pip

echo "========== Instalando Docker =========="
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl start docker

groupadd docker || true
usermod -aG docker ubuntu

echo "========== Instalando Jenkins =========="
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update
apt install -y jenkins

systemctl stop jenkins
systemctl enable jenkins

usermod -aG docker jenkins

echo "========== Configurando segurança inicial do Jenkins =========="
mkdir -p /var/lib/jenkins/init.groovy.d

cat <<EOF > /var/lib/jenkins/init.groovy.d/security.groovy
import jenkins.model.*
import hudson.security.*
import jenkins.install.*

def instance = Jenkins.get()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin', '@TimeSyncJenkins2025')
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.installState = InstallState.INITIAL_SETUP_COMPLETED

instance.save()
EOF

chown -R jenkins:jenkins /var/lib/jenkins

echo "========== Configurando ambiente SSH para o Jenkins =========="
mkdir -p /var/lib/jenkins/.ssh
cp /home/ubuntu/.ssh/Key-Private-MYSQL-02.pem /var/lib/jenkins/.ssh/Key-Private-MYSQL-02.pem
cp /home/ubuntu/.ssh/Key-Private-Python-01.pem /var/lib/jenkins/.ssh/Key-Private-Python-01.pem

chmod 400 /var/lib/jenkins/.ssh/Key-Private-MYSQL-02.pem
chmod 400 /var/lib/jenkins/.ssh/Key-Private-Python-01.pem

chown -R jenkins:jenkins /var/lib/jenkins/.ssh

ssh-keyscan -H ${DB_HOST} >> /var/lib/jenkins/.ssh/known_hosts || true
ssh-keyscan -H ${PYTHON_HOST} >> /var/lib/jenkins/.ssh/known_hosts || true

chmod 644 /var/lib/jenkins/.ssh/known_hosts
chown jenkins:jenkins /var/lib/jenkins/.ssh/known_hosts

echo "========== Instalando AWS CLI =========="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

aws --version

echo "========== Reiniciando Jenkins =========="
systemctl start jenkins
systemctl restart jenkins

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
done

# Reinicia Jenkins para aplicar plugins
java -jar $JENKINS_CLI -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASS safe-restart

# Aguarda reinicialização
sleep 30
while ! nc -z localhost 8080; do
  sleep 5
done

echo "Criando Job de Deploy da Lambda RAW(ETL) via Jenkins CLI..."
cat <<EOF | java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ -auth admin:@TimeSyncJenkins2025 create-job Deploy-Lambdas-Raw-ETL
<flow-definition plugin="workflow-job">
  <description>Pipeline para clonar repositório de Lambdas e fazer deploy na AWS</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps">
    <script>
    pipeline {
        
        agent any

        environment {
            AWS_REGION = 'us-east-1'
            AWS_DEFAULT_REGION = 'us-east-1'
            PATH = "\$PATH:/usr/local/bin" // Garante que o AWS CLI está no PATH
        }

        stages {
            stage('Clonar Código') {
                steps {
                    git branch: 'main', url: 'https://github.com/TimeSync-Grupo-07/Lambda_functions-Python.git'
                }
            }

            stage('Instalar Dependências e Criar Zips') {
                steps {
                    sh '''
                        cd lambda_raw_function/
                        zip lambda_raw_function.zip lambda_function.py
                    '''
                }
            }

            stage('Enviar para o Bucket') {
                steps {
                    sh '''
                        aws s3 cp lambda_raw_function/lambda_raw_function.zip s3://timesync-backup-841051091018312111099/deploy_functions_lambda/lambda_raw_function.zip
                    '''
                }
            }

            stage('Deploy para Lambda') {
                steps {
                    sh '''
                        aws lambda update-function-code \
                        --function-name timesync-etl-function-841051091018312111099 \
                        --s3-bucket timesync-backup-841051091018312111099 \
                        --s3-key deploy_functions_lambda/lambda_raw_function.zip > /dev/null
                    '''
                }
            }

            stage('Limpar Tudo') {
                steps {
                    sh '''
                        echo "Limpando arquivo do bucket S3..."
                        aws s3 rm s3://timesync-backup-841051091018312111099/deploy_functions_lambda/lambda_raw_function.zip
                    '''
                }
            }
        }
    }
    </script>
    <sandbox>true</sandbox>
  </definition>
</flow-definition>
EOF

echo "Criando Job de Deploy da Lambda TRUSTED(insert) via Jenkins CLI..."
cat <<EOF | java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ -auth admin:@TimeSyncJenkins2025 create-job Deploy-Lambdas-Trusted-INSERT
<flow-definition plugin="workflow-job">
  <description>Pipeline para clonar repositório de Lambdas e fazer deploy na AWS</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps">
    <script>
    pipeline {
        
        agent any

        environment {
            AWS_REGION = 'us-east-1'
            AWS_DEFAULT_REGION = 'us-east-1'
            PATH = "\$PATH:/usr/local/bin"
        }

        stages {
            stage('Clonar Código') {
                steps {
                    git branch: 'main', url: 'https://github.com/TimeSync-Grupo-07/Lambda_functions-Python.git'
                }
            }

            stage('Instalar Dependências e Criar Zips') {
                steps {
                    sh '''
                        cd lambda_trusted_function/
                        zip lambda_trusted_function.zip lambda_function.py
                    '''
                }
            }

            stage('Enviar para o Bucket') {
                steps {
                    sh '''
                        aws s3 cp lambda_trusted_function/lambda_trusted_function.zip s3://timesync-backup-841051091018312111099/deploy_functions_lambda/lambda_trusted_function.zip
                    '''
                }
            }

            stage('Deploy para Lambda') {
                steps {
                    sh '''
                        aws lambda update-function-code \
                        --function-name timesync-insert-functions-841051091018312111099 \
                        --s3-bucket timesync-backup-841051091018312111099 \
                        --s3-key deploy_functions_lambda/lambda_trusted_function.zip > /dev/null
                    '''
                }
            }

            stage('Limpar Tudo') {
                steps {
                    sh '''
                        echo "Limpando arquivo do bucket S3..."
                        aws s3 rm s3://timesync-backup-841051091018312111099/deploy_functions_lambda/lambda_trusted_function.zip
                    '''
                }
            }
        }
    }
    </script>
    <sandbox>true</sandbox>
  </definition>
</flow-definition>
EOF

echo "Criando Job de Deploy da Lambda TRUSTED(insert) via Jenkins CLI..."
cat <<EOF | java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ -auth admin:@TimeSyncJenkins2025 create-job Deploy-Lambdas-Backup-INSERT
<flow-definition plugin="workflow-job">
  <description>Pipeline para clonar repositório de Lambdas e fazer deploy na AWS</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps">
    <script>
    pipeline {
        
        agent any

        environment {
            AWS_REGION = 'us-east-1'
            AWS_DEFAULT_REGION = 'us-east-1'
            PATH = "\$PATH:/usr/local/bin"
        }

        stages {
            stage('Clonar Código') {
                steps {
                    git branch: 'main', url: 'https://github.com/TimeSync-Grupo-07/Lambda_functions-Python.git'
                }
            }

            stage('Instalar Dependências e Criar Zips') {
                steps {
                    sh '''
                        cd lambda_backup_function/
                        zip lambda_backup_function.zip lambda_function.py
                    '''
                }
            }

            stage('Enviar para o Bucket') {
                steps {
                    sh '''
                        aws s3 cp lambda_backup_function/lambda_backup_function.zip s3://timesync-backup-841051091018312111099/deploy_functions_lambda/lambda_backup_function.zip
                    '''
                }
            }

            stage('Deploy para Lambda') {
                steps {
                    sh '''
                        aws lambda update-function-code \
                        --function-name timesync-backup-function-841051091018312111099 \
                        --s3-bucket timesync-backup-841051091018312111099 \
                        --s3-key deploy_functions_lambda/lambda_backup_function.zip > /dev/null
                    '''
                }
            }

            stage('Limpar Tudo') {
                steps {
                    sh '''
                        echo "Limpando arquivo do bucket S3..."
                        aws s3 rm s3://timesync-backup-841051091018312111099/deploy_functions_lambda/lambda_backup_function.zip
                    '''
                }
            }
        }
    }
    </script>
    <sandbox>true</sandbox>
  </definition>
</flow-definition>
EOF

echo "========== Seed Job criado! =========="

echo "========== User Data finalizado com sucesso! =========="
variable "timesync-administrador-conta-id" {
  description = "ID da conta AWS administradora"
  type        = string
}

variable "timesync-bucket-raw-bucket_name" {
  description = "Nome do bucket raw (dados brutos)"
  type        = string
}

variable "timesync-bucket-backup-bucket_name" {
  description = "Nome do bucket backup (cópias de segurança)"
  type        = string
}

variable "timesync-bucket-trusted-bucket_name" {
  description = "Nome do bucket trusted (dados processados e confiáveis)"
  type        = string
}

variable "timesync-db-host" {
  description = "Host do banco de dados MySQL na EC2"
  type        = string
}

variable "timesync-db-name" {
  description = "Nome do banco de dados MySQL"
  type        = string
}

variable "timesync-db-user" {
  description = "Usuário do banco de dados MySQL"
  type        = string
}

variable "timesync-db-password" {
  description = "Senha do banco de dados MySQL"
  type        = string
  sensitive   = true
}

variable "timesync-private-subnet-id" {
  description = "ID da subrede privada onde está a EC2 com MySQL"
  type        = string
}

variable "timesync-db-security-group-id" {
  description = "ID do security group da EC2 com MySQL"
  type        = string
}

# Variáveis opcionais para configurações adicionais (se necessário)
variable "timesync-lambda-memory-size" {
  description = "Tamanho de memória padrão para as funções Lambda"
  type        = number
  default     = 128
}

variable "timesync-lambda-timeout" {
  description = "Timeout padrão para as funções Lambda"
  type        = number
  default     = 60
}

variable "timesync-region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "timesync-environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "timesync-tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
  default = {
    Project     = "TimeSync"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
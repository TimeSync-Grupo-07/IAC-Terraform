variable "timesync-vpc-id" {
  type = string
}

variable "timesync-subrede-publica-id" {
  type = string
}

variable "timesync-subrede-privada-apps-id" {
  type = string
}

variable "timesync-subrede-privada-banco_de_dados-id" {
  type = string
}

variable "timesync-ami-padrao"{
  type = string
}

variable "timesync-grupo_de_seguranca-publico-servidor_web-id" {
  type = string
}

variable "timesync-grupo_de_seguranca-publico-central_monitoramento-id" {
  type = string
}

variable "timesync-grupo_de_seguranca-privado-banco_de_dados-id" {
  type = string
}

variable "timesync-grupo_de_seguranca-privado-transformacao_de_dados-id" {
  type = string
}

variable "timesync-grupo_de_seguranca-privado-api-id" {
  type = string
}

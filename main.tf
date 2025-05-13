provider "aws" {
  region = "us-east-1"
}

module "rede" {
  source = "./modules/rede"

  timesync-vpc-cidr_block = "10.0.0.0/23"
  timesync-subrede-publica-cidr_block = "10.0.0.0/24"
  timesync-subrede-privada-apps-cidr_block = "10.0.1.0/25"
  timesync-subrede-privada-banco_de_dados-cidr_block = "10.0.1.128/25"
  availability_zone = "us-east-1a"

}

module "maquinas" {

  depends_on = [ module.rede ]

  source = "./modules/maquinas"

  timesync-vpc-id = module.rede.timesync-vpc-id
  timesync-subrede-publica-id = module.rede.timesync-subrede-publica-id
  timesync-subrede-privada-apps-id = module.rede.timesync-subrede-privada-apps-id
  timesync-subrede-privada-banco_de_dados-id = module.rede.timesync-subrede-privada-banco_de_dados-id
  timesync-ami-padrao = "ami-0f9de6e2d2f067fca"
  timesync-grupo_de_seguranca-publico-servidor_web-id = module.rede.timesync-grupo_de_seguranca-publico-servidor_web-id
  timesync-grupo_de_seguranca-publico-central_monitoramento-id = module.rede.timesync-grupo_de_seguranca-publico-central_monitoramento-id
  timesync-grupo_de_seguranca-privado-banco_de_dados-id = module.rede.timesync-grupo_de_seguranca-privado-banco_de_dados-id
  timesync-grupo_de_seguranca-privado-transformacao_de_dados-id = module.rede.timesync-grupo_de_seguranca-privado-transformacao_de_dados-id
  timesync-grupo_de_seguranca-privado-api-id = module.rede.timesync-grupo_de_seguranca-privado-api-id
}

module "acls" {
  source                     = "./modules/acls"

  timesync-vpc-id = module.rede.timesync-vpc-id
  timesync-vpc-cidr_block = module.rede.timesync-vpc-cidr_block
  timesync-subrede-publica-id = module.rede.timesync-subrede-publica-id
  timesync-subrede-privada-apps-id = module.rede.timesync-subrede-privada-apps-id
  timesync-subrede-privada-banco_de_dados-id = module.rede.timesync-subrede-privada-banco_de_dados-id

  depends_on = [ module.maquinas ]
}

# module "lambda" {

#   source = "./modules/lambda_functions"

#   private_subnet_ids = [module.rede.private_python_subnet_id,module.rede.private_mysql_subnet_id]
#   raw_bucket_name = "timesync-raw-841051091018312111099"
#   trusted_bucket_name = "timesync-trusted-841051091018312111099"
#   account_id = "005948301962"
#   backup_bucket_name = "timesync-backup-841051091018312111099"
#   raw_topic_arn = "arn:aws:sns:us-east-1:005948301962:Alerting_sucess_backup"
# }
provider "aws" {
  region = "us-east-1"
}

module "rede" {
  source = "./modules/rede"

  timesync-vpc-cidr_block = "10.0.0.0/23"
  timesync-subrede-publica-cidr_block = "10.0.0.0/24"
  timesync-subrede-privada-apps-cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

}


module "maquinas" {

  depends_on = [ module.rede ]

  source = "./modules/maquinas"

  timesync-vpc-id = module.rede.timesync-vpc-id
  timesync-subrede-publica-id = module.rede.timesync-subrede-publica-id
  timesync-subrede-privada-apps-id = module.rede.timesync-subrede-privada-apps-id
  timesync-ami-padrao = "ami-0f9de6e2d2f067fca"
  timesync-grupo_de_seguranca-publico-servidor_web-id = module.rede.timesync-grupo_de_seguranca-publico-servidor_web-id
  timesync-grupo_de_seguranca-publico-captura_dados-id = module.rede.timesync-grupo_de_seguranca-publico-captura_dados-id
  timesync-grupo_de_seguranca-privado-api-db-id = module.rede.timesync-grupo_de_seguranca-privado-api-db-id
}

module "s3" {
  
  source = "./modules/s3"

}

module "lambda" {

  source = "./modules/lambda_functions"

  timesync-bucket-raw-bucket_name = module.s3.bucket_arn_raw
  timesync-bucket-trusted-bucket_name = module.s3.bucket_arn_trusted
  timesync-bucket-backup-bucket_name = module.s3.bucket_arn_backup
  timesync-administrador-conta-id = "562681233141"
  timesync-db-host                    = module.maquinas.timesync-instancia-privada-api-db-private_ip
  timesync-db-name                    = "Timesync"
  timesync-db-user                    = "insertion"
  timesync-db-password                = "@TimeSyncInsertion"
  timesync-private-subnet-id          = module.rede.timesync-subrede-privada-apps-id
  timesync-db-security-group-id       = module.rede.timesync-grupo_de_seguranca-privado-api-db-id
  timesync-region                     = "us-east-1"

}
provider "aws" {
  region = "us-east-1"
}

module "rede" {
  source = "./modules/rede"

  vpc_cidr_block           = "10.0.0.0/23"
  public_subnet_cidr_block = "10.0.0.0/24"
  private_api_subnet_cidr_block = "10.0.1.0/25"
  private_mysql_subnet_cidr_block = "10.0.1.128/25"
  availability_zone        = "us-east-1a"
}

module "maquinas" {

  depends_on = [ module.rede ]

  source                     = "./modules/maquinas"

  vpc_id = module.rede.vpc_id
  public_subnet_id           = module.rede.public_subnet_id
  private_python_subnet_id   = module.rede.private_python_subnet_id
  private_mysql_subnet_id    = module.rede.private_mysql_subnet_id
  public_sg_id               = module.rede.public_sg_id
  private_sg_api_id          = module.rede.private_sg_api_id
  private_sg_database_id     = module.rede.private_sg_database_id
}

module "acls" {
  source                     = "./modules/acls"
  vpc_id                     = module.rede.vpc_id
  vpc_cidr_block             = module.rede.vpc_cidr_block
  public_subnet_id           = module.rede.public_subnet_id
  private_python_subnet_id   = module.rede.private_python_subnet_id
  private_mysql_subnet_id    = module.rede.private_mysql_subnet_id

  depends_on = [ module.maquinas ]
}

module "lambda" {

  source = "./modules/lambda_functions"

  private_subnet_ids = [module.rede.private_python_subnet_id,module.rede.private_mysql_subnet_id]
  raw_bucket_name = "timesync-raw-841051091018312111099"
  trusted_bucket_name = "timesync-trusted-841051091018312111099"
  account_id = "005948301962"
  backup_bucket_name = "timesync-backup-841051091018312111099"
  raw_topic_arn = "arn:aws:sns:us-east-1:005948301962:Alerting_sucess_backup"
}
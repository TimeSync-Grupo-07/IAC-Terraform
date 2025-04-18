provider "aws" {
  region = "us-east-1"
}

# Carrega variáveis do ambiente
locals {
  env_vars = {
    email_address = var.email_address != "" ? var.email_address : "default@example.com"
    mysql_user    = var.mysql_user
    mysql_password = var.mysql_password
    mysql_db      = var.mysql_db
    account_id    = var.account_id
  }
}

module "rede" {
  source = "./modules/rede"

  vpc_cidr_block           = "10.0.0.0/23"
  public_subnet_cidr_block = "10.0.0.0/24"
  private_python_subnet_cidr_block = "10.0.1.0/25"
  private_mysql_subnet_cidr_block = "10.0.1.128/25"
  availability_zone        = "us-east-1a"
}

module "maquinas" {
  source                     = "./modules/maquinas"

  vpc_id = module.rede.vpc_id
  public_subnet_id           = module.rede.public_subnet_id
  private_python_subnet_id   = module.rede.private_python_subnet_id
  private_mysql_subnet_id    = module.rede.private_mysql_subnet_id
  public_sg_id               = module.rede.public_sg_id
  private_sg_id              = module.rede.private_sg_id
}

module "s3" {
  source = "./modules/s3"

  vpc_id               = module.rede.vpc_id
  private_route_table_id = module.rede.private_route_table_id
  region               = "us-east-1"
}

module "acls" {
  source                     = "./modules/acls"
  vpc_id                     = module.rede.vpc_id
  vpc_cidr_block             = module.rede.vpc_cidr_block
  public_subnet_id           = module.rede.public_subnet_id
  private_python_subnet_id   = module.rede.private_python_subnet_id
  private_mysql_subnet_id    = module.rede.private_mysql_subnet_id
}

module "sns" {
  source        = "./modules/sns"
  email_address = local.env_vars.email_address
}

module "lambda" {
  source = "./modules/lambda_functions"

  private_subnet_ids    = [module.rede.private_python_subnet_id, module.rede.private_mysql_subnet_id]
  lambda_sg_id          = module.rede.lambda_sg_id
  raw_bucket_name       = module.s3.raw_bucket_name
  trusted_bucket_name   = module.s3.trusted_bucket_name
  mysql_host            = module.maquinas.private_mysql_ip
  mysql_user            = local.env_vars.mysql_user
  mysql_password        = local.env_vars.mysql_password
  mysql_db              = local.env_vars.mysql_db
  account_id            = local.env_vars.account_id
}
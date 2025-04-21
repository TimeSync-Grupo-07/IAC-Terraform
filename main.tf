provider "aws" {
  region = "us-east-1"
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
  db_pass = "urubu100"
  db_user = "root"
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

  depends_on = [ module.maquinas ]
}

module "email_sqs" {
  source     = "./modules/sqs"
  queue_name = "fila-emails"
}
provider "aws" {
  region = "us-east-1"
}

module "rede" {
  source = "./modules/rede"

  vpc_cidr_block           = "10.0.0.0/23"
  public_subnet_cidr_block = "10.0.0.0/24"
  private_subnet_cidr_block = "10.0.1.0/24"
  availability_zone        = "us-east-1a"
}

module "maquinas" {
  source = "./modules/maquinas"

  vpc_id = module.rede.vpc_id
  public_subnet_id = module.rede.public_subnet_id
  private_subnet_id = module.rede.private_subnet_id
  public_sg_id = module.rede.public_sg_id
  private_sg_api_id = module.rede.private_sg_api_id
  private_sg_db_id = module.rede.private_sg_db_id

  depends_on = [ module.rede ]
}

module "s3" {
  source = "./modules/s3"

  vpc_id               = module.rede.vpc_id
  private_route_table_id = module.rede.private_route_table_id
  region               = "us-east-1"

  depends_on = [module.rede]
}

module "acls" {
  source = "./modules/acls"

  vpc_id           = module.rede.vpc_id
  vpc_cidr_block   = "10.0.0.0/23"
  public_subnet_id = module.rede.public_subnet_id
  private_subnet_id = module.rede.private_subnet_id

  depends_on = [
    module.maquinas
  ]
}
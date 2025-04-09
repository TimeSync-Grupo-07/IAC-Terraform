# Outputs do módulo de rede
output "vpc_id" {
  value = module.rede.vpc_id
}

output "public_subnet_id" {
  value = module.rede.public_subnet_id
}

output "private_subnet_id" {
  value = module.rede.private_subnet_id
}

output "public_sg_id" {
  value = module.rede.public_sg_id
}

output "private_sg_api_id" {
  value = module.rede.private_sg_api_id
}

output "private_sg_db_id" {
  value = module.rede.private_sg_db_id
}

output "public_acl_id" {
  value = module.acls.public_acl_id
}

output "private_acl_id" {
  value = module.acls.private_acl_id
}

# Outputs do módulo de máquinas
output "public_instance_public_ip" {
  value = module.maquinas.public_instance_public_ip
}

output "public_instance_id" {
  value = module.maquinas.public_instance_id
}

output "private_instance_api_private_ip" {
  value = module.maquinas.private_instance_api_private_ip
}

output "private_instance_api_id" {
  value = module.maquinas.private_instance_api_id
}

output "private_instance_db_private_ip" {
  value = module.maquinas.private_instance_db_private_ip
}

output "private_instance_db_id" {
  value = module.maquinas.private_instance_db_id
}
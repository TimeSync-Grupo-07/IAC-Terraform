output "private_route_table_id" {
  value = aws_route_table.private.id
}
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "private_sg_id" {
  value = aws_security_group.private_sg.id
}

# output "public_acl_id" {
#   value = module.acls.public_acl_id
# }

# output "private_acl_id" {
#   value = module.acls.private_acl_id
# }
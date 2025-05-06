output "public_acl_id" {
  value = aws_network_acl.public.id
}

output "private_acl_id_1" {
  value = aws_network_acl.private_1.id
}

output "private_acl_id_2" {
  value = aws_network_acl.private_2.id
}

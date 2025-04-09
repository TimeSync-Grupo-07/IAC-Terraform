output "public_acl_id" {
  value = aws_network_acl.public.id
}

output "private_acl_id" {
  value = aws_network_acl.private.id
}
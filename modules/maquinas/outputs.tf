output "public_instance_public_ip" {
  value = aws_instance.public_instance_web_server.public_ip
}

output "public_instance_id" {
  value = aws_instance.public_instance_web_server.id
}

output "private_instance_api_private_ip" {
  value = aws_instance.private_instance_api.private_ip
}

output "private_instance_api_id" {
  value = aws_instance.private_instance_api.id
}

output "private_instance_db_private_ip" {
  value = aws_instance.private_instance_db.private_ip
}

output "private_instance_db_id" {
  value = aws_instance.private_instance_db.id
}
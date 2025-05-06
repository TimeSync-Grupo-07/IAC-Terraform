output "public_instance_public_ip" {
  value = aws_instance.public_instance.public_ip
}

output "public_instance_id" {
  value = aws_instance.public_instance.id
}

output "public_ip" {
  value = aws_instance.public_instance.public_ip
}

output "private_python_ip" {
  value = aws_instance.python_instance.private_ip
}

output "private_mysql_ip" {
  value = aws_instance.mysql_instance.private_ip
}

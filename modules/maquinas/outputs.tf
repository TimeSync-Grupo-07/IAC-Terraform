output "timesync-instancia-publica-servidor_web-public_ip" {
  value = aws_instance.timesync-instancia-publica-servidor_web.public_ip
}

output "timesync-instancia-publica-captura_dados-public_ip" {
  value = aws_instance.timesync-instancia-publica-captura_dados.public_ip
}

output "timesync-instancia-privada-api-db-private_ip" {
  value = aws_instance.timesync-instancia-privada-api_db.private_ip
}
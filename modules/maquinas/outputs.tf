output "timesync-instancia-publica-servidor_web-public_ip" {
  value = aws_instance.timesync-instancia-publica-servidor_web.public_ip
}

output "timesync-instancia-publica-central_monitoramento-public_ip" {
  value = aws_instance.timesync-instancia-publica-central_monitoramento.public_ip
}

output "timesync-instancia-privada-transformacao_de_dados-private_ip" {
  value = aws_instance.timesync-instancia-privada-transformacao_de_dados.private_ip
}

output "timesync-instancia-privada-banco_de_dados-private_ip" {
  value = aws_instance.timesync-instancia-privada-banco_de_dados.private_ip
}

output "timesync-instancia-privada-api-private_ip" {
  value = aws_instance.timesync-instancia-privada-api.private_ip
}
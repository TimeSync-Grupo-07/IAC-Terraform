output "timesync-instancia-publica-servidor_web-public_ip" {
  value = aws_instance.timesync-instancia-publica-servidor_web.public_ip
}

output "timesync-instancia-publica-monitoramento-controle-public_ip" {
  value = aws_instance.timesync-instancia-monitoramento-controle.public_ip
}

output "timesync-instancia-publica-captura_dados-public_ip" {
  value = aws_instance.timesync-instancia-publica-captura_dados.public_ip
}

output "timesync-instancia-privada-api-db-private_ip" {
  value = aws_instance.timesync-instancia-privada-api_db.private_ip
}

output "servidor_web_id" {
  value = aws_instance.timesync-instancia-publica-servidor_web.id
}

output "monitoramento_controle_id" {
  value = aws_instance.timesync-instancia-monitoramento-controle.id
}

output "captura_dados_id" {
  value = aws_instance.timesync-instancia-publica-captura_dados.id
}

output "api_db_id" {
  value = aws_instance.timesync-instancia-privada-api_db.id
}

output "chave_servidor_web" {
  value = aws_key_pair.timesync-chave-public-servidor_web.key_name
}

output "chave_captura_dados" {
  value = aws_key_pair.timesync-chave-public-captura_dados.key_name
}

output "chave_api_db" {
  value = aws_key_pair.timesync-chave-private-api-db.key_name
}

output "chave_monitoramento_controle" {
  value = aws_key_pair.timesync-chave-publica-monitoramento-controle.key_name
}
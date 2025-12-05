output "timesync-vpc-id" {
  value = aws_vpc.timesync-vpc.id
}

output "timesync-vpc-cidr_block" {
  value = aws_vpc.timesync-vpc.cidr_block
}

output "timesync-tabelas_de_rotas-privada-id" {
  value = aws_route_table.timesync-tabelas_de_rotas-privada.id
}

output "timesync-subrede-publica-id" {
  value = aws_subnet.timesync-subrede-publica.id
}

output "timesync-subrede-privada-apps-id" {
  value = aws_subnet.timesync-subrede-privada-apps.id
}

output "timesync-grupo_de_seguranca-publico-servidor_web-id" {
  value = aws_security_group.timesync-grupo_de_seguranca-publico-servidor_web.id
}

output "timesync-grupo_de_seguranca-publico-monitoramento-controle-id" {
  value = aws_security_group.timesync-grupo_de_seguranca-publico-monitoramento-controle.id
}

output "timesync-grupo_de_seguranca-publico-captura_dados-id" {
  value = aws_security_group.timesync-grupo_de_seguranca-publico-captura_dados.id
}

output "timesync-grupo_de_seguranca-privado-api-db-id" {
  value = aws_security_group.timesync-grupo_de_seguranca-privado-api-db.id
}
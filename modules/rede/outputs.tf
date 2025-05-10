output "timesync-vpc-id" {
  value = aws_vpc.timesync-vpc.id
}

output "timesync-vp-cidr_block" {
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

output "timesync-subrede-privada-banco_de_dados-id" {
  value = aws_subnet.timesync-subrede-privada-banco_de_dados.id
}

output "timesync-grupo_de_seguranca-publico-servidor_web-id" {
  value = aws_security_group.timesync-grupo_de_seguranca-publico-servidor_web.id
}

output "timesync-grupo_de_seguranca-publico-central_monitoramento-id" {
  value = aws_security_group.timesync-grupo_de_seguranca-publico-central_monitoramento.id
}

output "timesync-grupo_de_seguranca-api-id" {
  value = aws_security_group.timesync-grupo_de_seguranca-api.id
}

output "timesync-grupo_de_seguranca-banco_de_dados-id" {
  value = aws_security_group.timesync-grupo_de_seguranca-banco_de_dados.id
}

output "timesync-network_acess_control_list-publica-id" {
  value = aws_network_acl.timesync-network_acess_control_list-publica.id
}

output "timesync-network_acess_control_list-privada-apps-id" {
  value = aws_network_acl.timesync-network_acess_control_list-privada-apps.id
}

output "timesync-network_acess_control_list-privada-banco_de_dados-id" {
  value = aws_network_acl.timesync-network_acess_control_list-privada-database.id
}

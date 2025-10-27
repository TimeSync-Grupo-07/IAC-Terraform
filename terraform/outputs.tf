output "bastion_ip" {
  description = "IP da instância pública que servirá como bastion"
  value       = module.maquinas.timesync-instancia-publica-servidor_web-public_ip
}

output "public_hosts" {
  value = [
    {
      name      = "servidor_web"
      public_ip = module.maquinas.timesync-instancia-publica-servidor_web-public_ip
      key_file  = "../chaves/${module.maquinas.chave_servidor_web}.pem"
    },
    {
      name      = "captura_dados"
      public_ip = module.maquinas.timesync-instancia-publica-captura_dados-public_ip
      key_file  = "../chaves/${module.maquinas.chave_captura_dados}.pem"
    },
    {
      name      = "monitoramento-controle"
      public_ip = module.maquinas.timesync-instancia-publica-monitoramento-controle-public_ip
      key_file  = "../chaves/${module.maquinas.chave_monitoramento_controle}.pem"
    }
  ]
}

output "private_hosts" {
  value = [
    {
      name       = "api_db"
      private_ip = module.maquinas.timesync-instancia-privada-api-db-private_ip
      key_file   = "../chaves/${module.maquinas.chave_api_db}.pem"
    }
  ]
}

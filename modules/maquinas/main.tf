

resource "aws_key_pair" "timesync-chave-public-servidor_web" {
  key_name = "Key-public-servidor_web"
  public_key = file("${path.module}/chaves/Key-public-servidor_web.pem.pub")
}

resource "aws_key_pair" "timesync-chave-public-central_monitoramento" {
  key_name = "Key-public-central_monitoramento"
  public_key = file("${path.module}/chaves/Key-public-central_monitoramento.pem.pub")
}

resource "aws_key_pair" "timesync-chave-private-api" {
  key_name = "Key-private-api"
  public_key = file("${path.module}/chaves/Key-private-api.pem.pub")
}

resource "aws_key_pair" "timesync-chave-private-banco_de_dados" {
  key_name = "Key-private-banco_de_dados"
  public_key = file("${path.module}/chaves/Key-private-banco_de_dados.pem.pub")
}

resource "aws_key_pair" "timesync-chave-private-transformacao_de_dados" {
  key_name = "Key-private-transformacao_de_dados"
  public_key = file("${path.module}/chaves/Key-private-transformacao_de_dados.pem.pub")
}

resource "aws_instance" "timesync-instancia-publica-servidor_web" {
  ami                         = var.timesync-ami-padrao
  instance_type               = "t2.micro"
  subnet_id                   = var.timesync-subrede-publica-id
  vpc_security_group_ids      = [var.timesync-grupo_de_seguranca-publico-servidor_web-id]
  key_name                    = aws_key_pair.timesync-chave-public-servidor_web.key_name
  iam_instance_profile        = "LabInstanceProfile"
  associate_public_ip_address = true
  user_data = data.template_file.timesync-arquivo_de_inicializacao-servidor_web.rendered

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/chaves/Key-public-servidor_web.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/chaves/Key-private-banco_de_dados.pem"
    destination = "/home/ubuntu/.ssh/Key-private-banco_de_dados.pem"
  }

  provisioner "file" {
    source      = "${path.module}/chaves/Key-private-transformacao_de_dados.pem"
    destination = "/home/ubuntu/.ssh/Key-private-transformacao_de_dados.pem"
  }

  provisioner "file" {
    source      = "${path.module}/chaves/Key-private-api.pem"
    destination = "/home/ubuntu/.ssh/Key-private-api.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/.ssh/Key-private-banco_de_dados.pem",
      "chmod 400 /home/ubuntu/.ssh/Key-private-transformacao_de_dados.pem",
      "chmod 400 /home/ubuntu/.ssh/Key-private-api.pem"
    ]
  }

  tags = {
    Name = "timesync-instancia-publica-servidor_web"
  }

  depends_on = [aws_instance.timesync-instancia-privada-banco_de_dados]
}

resource "aws_instance" "timesync-instancia-publica-central_monitoramento" {
  ami                         = var.timesync-ami-padrao
  instance_type               = "t2.micro"
  subnet_id                   = var.timesync-subrede-publica-id
  vpc_security_group_ids      = [var.timesync-grupo_de_seguranca-publico-central_monitoramento-id]
  key_name                    = aws_key_pair.timesync-chave-public-central_monitoramento.key_name
  iam_instance_profile        = "LabInstanceProfile"
  associate_public_ip_address = true
  user_data = data.template_file.timesync-arquivo_de_inicializacao-central_monitoramento.rendered

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/chaves/Key-public-central_monitoramento.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/chaves/Key-private-banco_de_dados.pem"
    destination = "/home/ubuntu/.ssh/Key-private-banco_de_dados.pem"
  }

  provisioner "file" {
    source      = "${path.module}/chaves/Key-private-transformacao_de_dados.pem"
    destination = "/home/ubuntu/.ssh/Key-private-transformacao_de_dados.pem"
  }

  provisioner "file" {
    source      = "${path.module}/chaves/Key-private-api.pem"
    destination = "/home/ubuntu/.ssh/Key-private-api.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/.ssh/Key-private-banco_de_dados.pem",
      "chmod 400 /home/ubuntu/.ssh/Key-private-transformacao_de_dados.pem",
      "chmod 400 /home/ubuntu/.ssh/Key-private-api.pem"
    ]
  }

  tags = {
    Name = "timesync-instancia-publica-central_monitoramento"
  }

  depends_on = [aws_instance.timesync-instancia-privada-banco_de_dados]
}

resource "aws_instance" "timesync-instancia-privada-banco_de_dados" {
  ami                    = var.timesync-ami-padrao
  instance_type          = "t2.micro"
  subnet_id              = var.timesync-subrede-privada-banco_de_dados-id
  vpc_security_group_ids = [var.timesync-grupo_de_seguranca-privado-banco_de_dados-id]
  key_name               = aws_key_pair.timesync-chave-private-banco_de_dados.key_name
  iam_instance_profile   = "LabInstanceProfile"
  user_data = data.template_file.timesync-arquivo_de_inicializacao-banco_de_dados.rendered
  tags = {
    Name = "timesync-instancia-privada-banco_de_dados"
  }
}

  resource "aws_instance" "timesync-instancia-privada-transformacao_de_dados" {
    ami                    = var.timesync-ami-padrao
    instance_type          = "t2.micro"
    subnet_id              = var.timesync-subrede-privada-apps-id
    vpc_security_group_ids = [var.timesync-grupo_de_seguranca-privado-transformacao_de_dados-id]
    key_name               = aws_key_pair.timesync-chave-private-transformacao_de_dados.key_name
    iam_instance_profile   = "LabInstanceProfile"
    user_data = data.template_file.timesync-arquivo_de_inicializacao-transformacao_de_dados.rendered

    tags = {
      Name = "timesync-instancia-privada-transformacao_de_dados"
    }
  }

  resource "aws_instance" "timesync-instancia-privada-api" {
    ami                    = var.timesync-ami-padrao
    instance_type          = "t2.micro"
    subnet_id              = var.timesync-subrede-privada-apps-id
    vpc_security_group_ids = [var.timesync-grupo_de_seguranca-privado-api-id]
    key_name               = aws_key_pair.timesync-chave-private-api.key_name
    iam_instance_profile   = "LabInstanceProfile"
    user_data = data.template_file.timesync-arquivo_de_inicializacao-api.rendered

    tags = {
      Name = "timesync-instancia-privada-api"
    }
  }

data "template_file" "timesync-arquivo_de_inicializacao-servidor_web" {
  template = file("${path.module}/arquivos/user_data_public_servidor_web.sh.tpl")
  vars = {
    DB_HOST = aws_instance.timesync-instancia-privada-banco_de_dados.private_ip,
    PYTHON_HOST = aws_instance.timesync-instancia-privada-transformacao_de_dados.private_ip
  }
  
}

data "template_file" "timesync-arquivo_de_inicializacao-central_monitoramento" {
  template = file("${path.module}/arquivos/user_data_public_central_monitoramento.sh.tpl")
}

data "template_file" "timesync-arquivo_de_inicializacao-banco_de_dados" {
  template = file("${path.module}/arquivos/user_data_private_banco_de_dados.sh.tpl")
}

data "template_file" "timesync-arquivo_de_inicializacao-api" {
  template = file("${path.module}/arquivos/user_data_private_api.sh.tpl")
}

data "template_file" "timesync-arquivo_de_inicializacao-transformacao_de_dados" {
  template = file("${path.module}/arquivos/user_data_private_transformacao_de_dados.sh.tpl")
}

  resource "null_resource" "verificacao-instalacao-docker-banco_de_dados" {
    depends_on = [aws_instance.timesync-instancia-publica-servidor_web]

    provisioner "remote-exec" {
      connection {
        type                = "ssh"
        user                = "ubuntu"
        private_key         = file("${path.module}/chaves/Key-private-banco_de_dados.pem")
        host                = aws_instance.timesync-instancia-privada-banco_de_dados.private_ip
        bastion_host        = aws_instance.timesync-instancia-publica-servidor_web.public_ip
        bastion_user        = "ubuntu"
        bastion_private_key = file("${path.module}/chaves/Key-public-servidor_web.pem")
      }

      inline = [
        "while ! systemctl is-active docker; do echo 'Esperando Docker subir...'; sleep 5; done",
        "echo Docker iniciado com sucesso"
      ]

    }

  }

  resource "null_resource" "verificacao-instalacao-docker-tranformacao_de_dados" {
    depends_on = [aws_instance.timesync-instancia-publica-servidor_web]

    provisioner "remote-exec" {
      connection {
        type                = "ssh"
        user                = "ubuntu"
        private_key         = file("${path.module}/chaves/Key-private-transformacao_de_dados.pem")
        host                = aws_instance.timesync-instancia-privada-transformacao_de_dados.private_ip
        bastion_host        = aws_instance.timesync-instancia-publica-servidor_web.public_ip
        bastion_user        = "ubuntu"
        bastion_private_key = file("${path.module}/chaves/Key-public-servidor_web.pem")
      }

      inline = [
        "while ! systemctl is-active docker; do echo 'Esperando Docker subir...'; sleep 5; done",
        "echo Docker iniciado com sucesso"
      ]

    }

  }

  resource "null_resource" "verificacao-instalacao-docker-servidor_web" {
    depends_on = [aws_instance.timesync-instancia-publica-servidor_web]

    provisioner "remote-exec" {
      connection {
        type                = "ssh"
        user                = "ubuntu"
        private_key         = file("${path.module}/chaves/Key-public-servidor_web.pem")
        host                = aws_instance.timesync-instancia-publica-servidor_web.public_ip
      }

      inline = [
        "while ! systemctl is-active docker; do echo 'Esperando Docker subir...'; sleep 5; done",
        "echo Docker iniciado com sucesso"
      ]

    }

  }




  resource "aws_key_pair" "timesync-chave-public-servidor_web" {
    key_name = "Key-public-servidor-web"
    public_key = file(".././chaves/Key-public-servidor-web.pem.pub")
  }

  resource "aws_key_pair" "timesync-chave-public-captura_dados" {
    key_name = "Key-public-captura-dados"
    public_key = file(".././chaves/Key-public-captura-dados.pem.pub")
  }

  resource "aws_key_pair" "timesync-chave-private-api-db" {
    key_name = "Key-private-api-db"
    public_key = file(".././chaves/Key-private-api-db.pem.pub")
  }

  resource "aws_instance" "timesync-instancia-publica-servidor_web" {
    ami                         = var.timesync-ami-padrao
    instance_type               = "t2.large"
    subnet_id                   = var.timesync-subrede-publica-id
    vpc_security_group_ids      = [var.timesync-grupo_de_seguranca-publico-servidor_web-id]
    key_name                    = aws_key_pair.timesync-chave-public-servidor_web.key_name
    iam_instance_profile        = "LabInstanceProfile"
    associate_public_ip_address = true

    ebs_block_device {
      device_name = "/dev/sda1"
      volume_size = 40
      volume_type = "standard"
    }

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(".././chaves/Key-public-servidor-web.pem")
      host        = self.public_ip
    }

    provisioner "file" {
      source      = ".././chaves/Key-private-api-db.pem"
      destination = "/home/ubuntu/.ssh/Key-private-api-db.pem"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod 400 /home/ubuntu/.ssh/Key-private-api-db.pem"
      ]
    }

    tags = {
      Name = "timesync-instancia-publica-servidor_web"
    }

    depends_on = [aws_instance.timesync-instancia-privada-api_db]
  }

  resource "aws_instance" "timesync-instancia-publica-captura_dados" {
    ami                         = var.timesync-ami-padrao
    instance_type               = "t2.medium"
    subnet_id                   = var.timesync-subrede-publica-id
    vpc_security_group_ids      = [var.timesync-grupo_de_seguranca-publico-captura_dados-id]
    key_name                    = aws_key_pair.timesync-chave-public-captura_dados.key_name
    iam_instance_profile        = "LabInstanceProfile"
    associate_public_ip_address = true

    ebs_block_device {
      device_name = "/dev/sda1"
      volume_size = 30
      volume_type = "standard"
    }

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(".././chaves/Key-public-captura-dados.pem")
      host        = self.public_ip
    }

    tags = {
      Name = "timesync-instancia-publica-captura_dados"
    }

    depends_on = [aws_instance.timesync-instancia-privada-api_db]
  }

  resource "aws_instance" "timesync-instancia-privada-api_db" {
    ami                    = var.timesync-ami-padrao
    instance_type          = "t2.medium"
    subnet_id              = var.timesync-subrede-privada-apps-id
    vpc_security_group_ids = [var.timesync-grupo_de_seguranca-privado-api-db-id]
    key_name               = aws_key_pair.timesync-chave-private-api-db.key_name
    iam_instance_profile   = "LabInstanceProfile"

    ebs_block_device {
      device_name = "/dev/sda1"
      volume_size = 30
      volume_type = "standard"
    }

    tags = {
      Name = "timesync-instancia-privada-api"
    }
  }



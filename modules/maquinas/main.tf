

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

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "standard"
  }

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

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "standard"
  }

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
  
  tags = {
    Name = "timesync-instancia-privada-banco_de_dados"
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "standard"
  }

}

resource "aws_instance" "timesync-instancia-privada-transformacao_de_dados" {
  ami                    = var.timesync-ami-padrao
  instance_type          = "t2.micro"
  subnet_id              = var.timesync-subrede-privada-apps-id
  vpc_security_group_ids = [var.timesync-grupo_de_seguranca-privado-transformacao_de_dados-id]
  key_name               = aws_key_pair.timesync-chave-private-transformacao_de_dados.key_name
  iam_instance_profile   = "LabInstanceProfile"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "standard"
  }

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

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "standard"
  }

  tags = {
    Name = "timesync-instancia-privada-api"
  }
}


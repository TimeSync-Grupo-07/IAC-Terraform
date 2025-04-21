
data "template_file" "user_data_public" {
  template = file("${path.module}/arquivos/user_data_node.sh.tpl")
}

data "template_file" "user_data_mysql" {
  template = file("${path.module}/arquivos/user_data_private.sh.tpl")
}

data "template_file" "user_data_python" {
  template = file("${path.module}/arquivos/user_data_private.sh.tpl")
}

resource "aws_instance" "public_instance" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.public_sg_id]
  key_name                    = "Key-Public-01"
  iam_instance_profile        = "LabInstanceProfile"
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data_public.rendered

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./chaves/Key-Public-01.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./chaves/Key-Private-MYSQL-02.pem"
    destination = "/home/ubuntu/.ssh/Key-Private-MYSQL-02.pem"
  }

  provisioner "file" {
    source      = "./chaves/Key-Private-Python-01.pem"
    destination = "/home/ubuntu/.ssh/Key-Private-Python-01.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/.ssh/Key-Private-Python-01.pem",
      "chmod 400 /home/ubuntu/.ssh/Key-Private-MYSQL-02.pem"
    ]
  }

  tags = {
    Name = "public-instance-jenkins"
  }

  depends_on = [aws_instance.mysql_instance]
}

  resource "aws_instance" "mysql_instance" {
    ami                    = "ami-04b4f1a9cf54c11d0"
    instance_type          = "t2.micro"
    subnet_id              = var.private_mysql_subnet_id
    vpc_security_group_ids = [var.private_sg_id]
    key_name               = "Key-Private-MYSQL-02"
    iam_instance_profile   = "LabInstanceProfile"
    user_data = data.template_file.user_data_mysql.rendered

    tags = {
      Name = "private-mysql-instance"
    }

  }

  resource "aws_instance" "python_instance" {
    ami                    = "ami-04b4f1a9cf54c11d0"
    instance_type          = "t2.micro"
    subnet_id              = var.private_python_subnet_id
    vpc_security_group_ids = [var.private_sg_id]
    key_name               = "Key-Private-Python-01"
    iam_instance_profile   = "LabInstanceProfile"
    user_data = data.template_file.user_data_python.rendered

    tags = {
      Name = "private-python-instance"
    }
  }

  resource "null_resource" "wait_for_docker_mysql" {
    depends_on = [aws_instance.python_instance]

    provisioner "remote-exec" {
      connection {
        type                = "ssh"
        user                = "ubuntu"
        private_key         = file("./chaves/Key-Private-MYSQL-02.pem")
        host                = aws_instance.mysql_instance.private_ip
        bastion_host        = aws_instance.public_instance.public_ip
        bastion_user        = "ubuntu"
        bastion_private_key = file("./chaves/Key-Public-01.pem")
      }

      inline = [
        "while ! systemctl is-active docker; do echo 'Esperando Docker subir...'; sleep 5; done",
        "echo Docker iniciado com sucesso"
      ]

    }

  }

  resource "null_resource" "wait_for_docker_python" {
    depends_on = [aws_instance.python_instance]

    provisioner "remote-exec" {
      connection {
        type                = "ssh"
        user                = "ubuntu"
        private_key         = file("./chaves/Key-Private-Python-01.pem")
        host                = aws_instance.python_instance.private_ip
        bastion_host        = aws_instance.public_instance.public_ip
        bastion_user        = "ubuntu"
        bastion_private_key = file("./chaves/Key-Public-01.pem")
      }

      inline = [
        "while ! systemctl is-active docker; do echo 'Esperando Docker subir...'; sleep 5; done",
        "echo Docker iniciado com sucesso"
      ]

    }

  }
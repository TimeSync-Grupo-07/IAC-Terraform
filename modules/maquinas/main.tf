resource "aws_instance" "public_instance" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.public_sg_id]
  key_name                    = "Key-Public-01"
  iam_instance_profile        = "LabInstanceProfile"
  associate_public_ip_address = true

  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file("./chaves/Key-Public-01.pem")
    host                = self.public_ip
  }

  provisioner "file" {
    source = "./chaves/Key-Private-MYSQL-02.pem"
    destination = "/home/ubuntu/.ssh/Key-Private-MYSQL-02.pem"
  }

  provisioner "file" {
    source = "./chaves/Key-Private-Python-01.pem"
    destination = "/home/ubuntu/.ssh/Key-Private-Python-01.pem"
  }

  tags = {
    Name = "public-instance"
  }
}

resource "aws_instance" "python_instance" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = var.private_python_subnet_id
  vpc_security_group_ids      = [var.private_sg_id]
  key_name                    = "Key-Private-Python-01"
  iam_instance_profile        = "LabInstanceProfile"

  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file("./chaves/Key-Private-Python-01.pem")
    host                = self.private_ip
    bastion_host        = aws_instance.public_instance.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("./chaves/Key-Public-01.pem")
  }

  tags = {
    Name = "private-python-instance"
  }
}

resource "aws_instance" "mysql_instance" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = var.private_mysql_subnet_id
  vpc_security_group_ids      = [var.private_sg_id]
  key_name                    = "Key-Private-MYSQL-02"
  iam_instance_profile        = "LabInstanceProfile"

  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file("./chaves/Key-Private-MYSQL-02.pem")
    host                = self.private_ip
    bastion_host        = aws_instance.public_instance.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("./chaves/Key-Public-01.pem")
  }

  tags = {
    Name = "private-mysql-instance"
  }
}

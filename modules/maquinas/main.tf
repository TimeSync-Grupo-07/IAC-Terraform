resource "aws_instance" "private_instance" {
  ami                  = "ami-04b4f1a9cf54c11d0"
  instance_type        = "t2.micro"
  subnet_id            = var.private_subnet_id
  vpc_security_group_ids = [var.private_sg_id]
  key_name            = "Key-Private-01"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./chaves/Key-Private-API-01.pem")
    host        = self.private_ip

    bastion_host        = aws_instance.public_instance.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("./chaves/Key-Public-Front-01.pem")
  }

  tags = {
    Name = "private-instance"
  }

}

resource "aws_instance" "public_instance" {
  ami                  = "ami-04b4f1a9cf54c11d0"
  instance_type        = "t2.micro"
  subnet_id            = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name            = "Key-Public-01"

  tags = {
    Name = "public-instance"
  }
}

output "api_private_ip" {
  value = aws_instance.private_instance.private_ip
}

output "public_ip" {
  value = aws_instance.public_instance.public_ip
}
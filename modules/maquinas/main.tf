resource "aws_instance" "private_instance_db" {
  ami                  = "ami-04b4f1a9cf54c11d0"
  instance_type        = "t2.micro"
  subnet_id            = var.private_subnet_id
  vpc_security_group_ids = [var.private_sg_db_id]
  key_name            = "Key-Private-DB-01"

  provisioner "file" {
    source      = "./automacoes/deploy_banco.sh"
    destination = "/home/ubuntu/deploy_banco.sh"    
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /home/ubuntu/deploy_banco.sh",
      "/home/ubuntu/deploy_banco.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./chaves/Key-Private-DB-01.pem")
    host        = self.private_ip
    bastion_host        = aws_instance.public_instance_web_server.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("./chaves/Key-Public-Front-01.pem")
  }

  tags = {
    Name = "private-instance-DB"
  }

}

resource "aws_instance" "private_instance_api" {
  ami                  = "ami-04b4f1a9cf54c11d0"
  instance_type        = "t2.micro"
  subnet_id            = var.private_subnet_id
  vpc_security_group_ids = [var.private_sg_api_id]
  key_name            = "Key-Private-API-01"

  provisioner "file" {
    source      = "./chaves/Key-Private-DB-01.pem"
    destination = "/home/ubuntu/.ssh/Key-Private-DB-01.pem"    
  }

  provisioner "file" {
    source      = "./automacoes/deploy_back.sh"
    destination = "/home/ubuntu/deploy_back.sh"    
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /home/ubuntu/deploy_back.sh",
      "chmod 400 /home/ubuntu/.ssh/Key-Private-DB-01.pem",
      "/home/ubuntu/deploy_back.sh ${aws_instance.private_instance_db.private_ip}"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./chaves/Key-Private-API-01.pem")
    host        = self.private_ip

    bastion_host        = aws_instance.public_instance_web_server.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("./chaves/Key-Public-Front-01.pem")
  }

  tags = {
    Name = "private-instance-API"
  }

  depends_on = [ aws_instance.private_instance_db ]
}

resource "aws_instance" "public_instance_web_server" {
  ami                  = "ami-04b4f1a9cf54c11d0"
  instance_type        = "t2.micro"
  subnet_id            = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name            = "Key-Public-Front-01"

  provisioner "file" {
    source      = "./automacoes/deploy_front.sh"
    destination = "/home/ubuntu/deploy_front.sh"
  }

  provisioner "file" {
    source      = "./automacoes/setup_nginx.sh"
    destination = "/home/ubuntu/setup_nginx.sh"
  }

  provisioner "file" {
    source      = "./chaves/Key-Private-API-01.pem"
    destination = "/home/ubuntu/.ssh/Key-Private-API-01.pem"    
  }

  provisioner "file" {
    source      = "./chaves/Key-Private-DB-01.pem"
    destination = "/home/ubuntu/.ssh/Key-Private-DB-01.pem"    
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /home/ubuntu/deploy_front.sh /home/ubuntu/setup_nginx.sh",
      "chmod 400 /home/ubuntu/.ssh/Key-Private-API-01.pem /home/ubuntu/.ssh/Key-Private-DB-01.pem",
      "/home/ubuntu/deploy_front.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./chaves/Key-Public-Front-01.pem")
    host        = self.public_ip
  }

  tags = {
    Name = "public-instance"
  }
}

resource "null_resource" "nginx_configuration" {
  depends_on = [
    aws_instance.public_instance_web_server,
    aws_instance.private_instance_api
  ]

  provisioner "remote-exec" {
    inline = [
      "/home/ubuntu/setup_nginx.sh ${aws_instance.public_instance_web_server.public_ip} ${aws_instance.private_instance_api.private_ip}"
    ]
    
    connection {
      type        = "ssh"
      host        = aws_instance.public_instance_web_server.public_ip
      user        = "ubuntu" 
      private_key = file("./chaves/Key-Public-Front-01.pem")
    }
  }

}

output "db_private_ip" {
  value = aws_instance.private_instance_db.private_ip
}

output "api_private_ip" {
  value = aws_instance.private_instance_api.private_ip
}

output "public_ip" {
  value = aws_instance.public_instance_web_server.public_ip
}
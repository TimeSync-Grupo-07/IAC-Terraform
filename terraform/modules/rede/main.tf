resource "aws_vpc" "timesync-vpc" {
  cidr_block = var.timesync-vpc-cidr_block

  tags = {
    Name = "timesync-vpc"
  }
}

resource "aws_subnet" "timesync-subrede-publica" {
  vpc_id                  = aws_vpc.timesync-vpc.id
  cidr_block              = var.timesync-subrede-publica-cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "timesync-subrede-publica"
  }
}

resource "aws_subnet" "timesync-subrede-privada-apps" {
  vpc_id            = aws_vpc.timesync-vpc.id
  cidr_block        = var.timesync-subrede-privada-apps-cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "timesync-subrede-privada-apps"
  }
}

resource "aws_internet_gateway" "timesync-gateway-internet" {
  vpc_id = aws_vpc.timesync-vpc.id

  tags = {
    Name = "timesync-gateway-internet"
  }
}

resource "aws_route_table" "timesync-tabela_de_rotas-publica" {
  vpc_id = aws_vpc.timesync-vpc.id

  route {
    cidr_block = var.timesync-vpc-cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.timesync-gateway-internet.id
  }

  tags = {
    Name = "timesync-tabela_de_rotas-publica"
  }
}

resource "aws_route_table_association" "associacao-tabela_de_rotas-subrede-publica" {
  subnet_id      = aws_subnet.timesync-subrede-publica.id
  route_table_id = aws_route_table.timesync-tabela_de_rotas-publica.id
}

resource "aws_eip" "timesync-gateway-ip" {
  domain = "vpc"

  tags = {
    Name = "timesync-gateway-ip"
  }

}

resource "aws_nat_gateway" "timesync-gateway-nat" {
  allocation_id = aws_eip.timesync-gateway-ip.id
  subnet_id     = aws_subnet.timesync-subrede-publica.id

  tags = {
    Name = "timesync-gateway-nat"
  }
}

resource "aws_route_table" "timesync-tabelas_de_rotas-privada" {
  vpc_id = aws_vpc.timesync-vpc.id

  route {
    cidr_block = var.timesync-vpc-cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.timesync-gateway-nat.id
  }

  tags = {
    Name = "timesync-tabelas_de_rotas-privada"
  }
}

resource "aws_route_table_association" "associacao-tabela_de_rotas-subrede-privada-app" {
  subnet_id      = aws_subnet.timesync-subrede-privada-apps.id
  route_table_id = aws_route_table.timesync-tabelas_de_rotas-privada.id
}

resource "aws_security_group" "timesync-grupo_de_seguranca-publico-servidor_web" {
  vpc_id = aws_vpc.timesync-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 993
    to_port = 993
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 9100
    to_port = 9100
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "timesync-grupo_de_seguranca-publico-servidor-web"
  }
}

resource "aws_security_group" "timesync-grupo_de_seguranca-publico-monitoramento-controle" {
  vpc_id = aws_vpc.timesync-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "timesync-grupo_de_seguranca-publico-servidor-web"
  }
}

resource "aws_security_group" "timesync-grupo_de_seguranca-publico-captura_dados" {
  vpc_id = aws_vpc.timesync-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "timesync-grupo_de_seguranca-publico-central_monitoramento"
  }
}

resource "aws_security_group" "timesync-grupo_de_seguranca-privado-api-db" {
  vpc_id = aws_vpc.timesync-vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.timesync-grupo_de_seguranca-publico-servidor_web.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.timesync-grupo_de_seguranca-publico-servidor_web.id]
  }

  ingress {
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "timesync-grupo_de_seguranca-privado-api-db"
  }
}
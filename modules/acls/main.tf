
resource "aws_network_acl" "public" {
  vpc_id = var.vpc_id

  # Entrada
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 8080
    to_port    = 8080
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 104
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32000
    to_port    = 65535
  }

  ingress {
    protocol = "tcp"
    rule_no = 105
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 993
    to_port = 993
  }

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "acl-public"
  }
}

resource "aws_network_acl" "private_1" {
  vpc_id = var.vpc_id

  # Entrada da própria VPC
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 8080
    to_port    = 8080
  }

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "acl-private"
  }
}

resource "aws_network_acl" "private_2" {
  vpc_id = var.vpc_id
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "acl-private"
  }
}

# Associações
resource "aws_network_acl_association" "public" {
  subnet_id      = var.public_subnet_id
  network_acl_id = aws_network_acl.public.id
}

resource "aws_network_acl_association" "private_python" {
  subnet_id      = var.private_python_subnet_id
  network_acl_id = aws_network_acl.private_1.id
}

resource "aws_network_acl_association" "private_mysql" {
  subnet_id      = var.private_mysql_subnet_id
  network_acl_id = aws_network_acl.private_2.id
}

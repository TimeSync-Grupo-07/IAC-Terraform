
resource "aws_network_acl" "timesync-network_acess_control_list-publica" {
  vpc_id = var.timesync-vpc-id

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
    from_port = 8888
    to_port = 8888
  }

  ingress {
    protocol = "tcp"
    rule_no = 106
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

resource "aws_network_acl" "timesync-network_acess_control_list-privada-apps" {
  vpc_id = var.timesync-vpc-id

  # Entrada da própria VPC
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.timesync-vpc-cidr_block
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.timesync-vpc-cidr_block
    from_port  = 8080
    to_port    = 8080
  }

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.timesync-vpc-cidr_block
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "acl-private"
  }
}

resource "aws_network_acl_association" "timesync-associacao-network_acess_control_list-publica" {
  subnet_id      = var.timesync-subrede-publica-id
  network_acl_id = aws_network_acl.timesync-network_acess_control_list-publica.id
}

resource "aws_network_acl_association" "timesync-associacao-network_acess_control_list-privada-apps" {
  subnet_id      = var.timesync-subrede-privada-apps-id
  network_acl_id = aws_network_acl.timesync-network_acess_control_list-privada-apps.id
}

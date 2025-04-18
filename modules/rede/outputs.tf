output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_python_subnet_id" {
  value = aws_subnet.private_python.id
}

output "private_mysql_subnet_id" {
  value = aws_subnet.private_mysql.id
}

output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "private_sg_id" {
  value = aws_security_group.private_sg.id
}

resource "aws_s3_bucket" "raw_bucket" {
  bucket = "raw-bucket-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name = "raw-bucket"
  }
}

resource "aws_s3_bucket" "trusted_bucket" {
  bucket = "trusted-bucket-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name = "trusted-bucket"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    var.private_route_table_id
  ]

  tags = {
    Name = "s3-vpc-endpoint"
  }
}

output "bucket_arn_raw" {
  value = aws_s3_bucket.raw_bucket.arn
}

output "bucket_arn_trusted" {
  value = aws_s3_bucket.trusted_bucket.arn
}

output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}
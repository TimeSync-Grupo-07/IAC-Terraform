output "raw_bucket_name" {
  value = aws_s3_bucket.raw_bucket.bucket
}

output "trusted_bucket_name" {
  value = aws_s3_bucket.trusted_bucket.bucket
}
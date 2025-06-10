
output "bucket_arn_raw" {
  value = aws_s3_bucket.raw_bucket.bucket
}

output "bucket_arn_trusted" {
  value = aws_s3_bucket.trusted_bucket.bucket
}

output "bucket_arn_backup" {
  value = aws_s3_bucket.backup.bucket
}
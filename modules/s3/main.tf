

resource "aws_s3_bucket" "raw_bucket" {
  
  bucket = "timesync-raw-841051091018312111099-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name = "timesync-raw-841051091018312111099"
  }

}

resource "aws_s3_bucket" "trusted_bucket" {
  
  bucket = "timesync-trusted-841051091018312111099-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name = "timesync-trusted-841051091018312111099"
  }

}

resource "aws_s3_bucket" "backup" {
  
  bucket = "timesync-backup-841051091018312111099-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name = "timesync-backup-841051091018312111099"
  }

}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_object" "pasta_pipefy_raw" {
  bucket = aws_s3_bucket.raw_bucket.bucket
  key = "pipefy/"
}

resource "aws_s3_object" "pasta_pipefy_trusted" {
  bucket = aws_s3_bucket.trusted_bucket.bucket
  key = "pipefy/"
}

resource "aws_s3_object" "pasta_pipefy_backup" {
  bucket = aws_s3_bucket.backup.bucket
  key = "pipefy/"
}

resource "aws_s3_object" "pasta_apontamentos_raw" {
  bucket = aws_s3_bucket.raw_bucket.bucket
  key = "apontamentos/"
}

resource "aws_s3_object" "pasta_apontamentos_trusted" {
  bucket = aws_s3_bucket.trusted_bucket.bucket
  key = "apontamentos/"
}

resource "aws_s3_object" "pasta_apontamentos_backup" {
  bucket = aws_s3_bucket.backup.bucket
  key = "apontamentos/"
}
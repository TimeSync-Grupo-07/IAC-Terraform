

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

resource "aws_s3_bucket" "backup_bucket" {
  
  bucket = "timesync-backup-841051091018312111099-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name = "timesync-backup-841051091018312111099"
  }

}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
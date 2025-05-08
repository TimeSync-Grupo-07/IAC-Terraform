variable "private_subnet_ids" {
  type = list(string)
}

variable "raw_bucket_name" {
  type = string
}

variable "trusted_bucket_name" {
  type = string
}

variable "backup_bucket_name" {
  type = string
}

variable "raw_topic_arn" {
  type = string
}

variable "account_id" {
  type = string
}
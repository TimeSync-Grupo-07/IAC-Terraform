variable "private_subnet_ids" {
  type = list(string)
}

variable "mysql_host" {
  type = string
}

variable "mysql_user" {
  type = string
}

variable "mysql_password" {
  type = string
  sensitive = true
}

variable "mysql_db" {
  type = string
}

variable "raw_bucket_name" {
  type = string
}

variable "trusted_bucket_name" {
  type = string
}

variable "account_id" {
  type = string
}

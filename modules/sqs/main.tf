resource "aws_sqs_queue" "email_queue" {
  name                      = var.queue_name
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400
  delay_seconds              = 0
}

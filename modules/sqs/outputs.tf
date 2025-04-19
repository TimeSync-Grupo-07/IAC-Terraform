output "queue_url" {
  value = aws_sqs_queue.email_queue.id
}

output "queue_arn" {
  value = aws_sqs_queue.email_queue.arn
}

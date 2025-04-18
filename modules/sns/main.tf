resource "aws_sns_topic" "email_notification" {
  name = "email-notification-topic"

  tags = {
    Name = "Email Notification Topic"
  }
}

resource "aws_sns_topic_subscription" "email_subscriber" {
  topic_arn = aws_sns_topic.email_notification.arn
  protocol  = "email"
  endpoint  = var.email_address
}


resource "aws_sns_topic" "notificacao_backup" {
  name = "timesync-notification_service-privado-topico"
}

resource "aws_sns_topic_subscription" "subinscricao" {
    for_each = toset(var.lista_email_equipe)

    topic_arn = aws_sns_topic.notificacao_backup.arn
    protocol = "email"
    endpoint = each.key
}
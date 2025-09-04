resource "aws_lambda_layer_version" "timesync-lambda-layer-mysql_connector" {
  filename            = "${path.module}/code/mysql_connector_python.zip"
  layer_name          = "timesync-lambda-layer-mysql_connector"
  compatible_runtimes = ["python3.11"]
}

resource "aws_lambda_function" "timesync-lambda-function-process_raw_data" {
  filename      = "${path.module}/code/codigo_padrao.zip"
  function_name = "timesync-etl-function-841051091018312111099"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      RAW_BUCKET = var.timesync-bucket-raw-bucket_name
    }
  }

  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python313:1"
  ]
}

resource "aws_lambda_function" "timesync-lambda-function-notification_team" {
  filename      = "${path.module}/code/codigo_padrao.zip"
  function_name = "timesync-mensage-function-841051091018312111099"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      SNS_TOPIC_ARN = var.timesync-sns-topico-information-arn
    }
  }

}

resource "aws_lambda_function" "timesync-lambda-function-process_trusted_data" {
  filename      = "${path.module}/code/codigo_padrao.zip"
  function_name = "timesync-insert-functions-841051091018312111099"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      TRUSTED_BUCKET = var.timesync-bucket-trusted-bucket_name
    }
  }

  layers = [
    aws_lambda_layer_version.timesync-lambda-layer-mysql_connector.arn
  ]
}

resource "aws_lambda_function" "timesync-lambda-function-process_backup_data" {
  filename      = "${path.module}/code/codigo_padrao.zip"
  function_name = "timesync-backup-function-841051091018312111099"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      BACKUP_BUCKET = var.timesync-bucket-backup-bucket_name
    }
  }
}

resource "aws_s3_bucket_notification" "timesync-lambda-trigger-process_trusted_data" {
  bucket = var.timesync-bucket-trusted-bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.timesync-lambda-function-process_trusted_data.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.timesync-lambda-permission-allow-invoke-process_trusted_data]
}

resource "aws_s3_bucket_notification" "timesync-lambda-trigger-process_backup_lambda" {
  bucket = var.timesync-bucket-raw-bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.timesync-lambda-function-process_backup_data.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".csv"
  }

  depends_on = [ aws_lambda_permission.timesync-lambda-permission-allow-invoke-process_backup_data ]
}

resource "aws_s3_bucket_notification" "timesync-lambda-function-notification_team" {
  bucket = var.timesync-bucket-backup-bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.timesync-lambda-function-notification_team.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".csv"
  }

  depends_on = [ aws_lambda_permission.timesync-lambda-permission-allow-invoke-notification_team ]
}

resource "aws_lambda_permission" "timesync-lambda-permission-allow-invoke-process_backup_data" {
  statement_id  = "AllowExecutionFromS3Raw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timesync-lambda-function-process_backup_data.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.timesync-bucket-raw-bucket_name}"
}

resource "aws_lambda_permission" "timesync-lambda-permission-allow-invoke-process_trusted_data" {
  statement_id  = "AllowExecutionFromS3Trusted"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timesync-lambda-function-process_trusted_data.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.timesync-bucket-trusted-bucket_name}"
}

resource "aws_lambda_permission" "timesync-lambda-permission-allow-invoke-notification_team" {
  statement_id  = "AllowExecutionFromS3Backup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timesync-lambda-function-notification_team.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.timesync-bucket-backup-bucket_name}"
}

resource "aws_lambda_permission" "timesync-lambda-permission-allow-invoke-process_raw_data" {
  statement_id  = "AllowBackupToInvokeRaw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timesync-lambda-function-process_raw_data.function_name
  principal     = "lambda.amazonaws.com"
  source_arn    = aws_lambda_function.timesync-lambda-function-process_backup_data.arn
}

resource "aws_lambda_function_event_invoke_config" "timesync-lambda-destination-" {
  function_name           = aws_lambda_function.timesync-lambda-function-process_backup_data.function_name
  qualifier               = "$LATEST"
  maximum_retry_attempts  = 0

  destination_config {
    on_success {
      destination = aws_lambda_function.timesync-lambda-function-process_raw_data.arn
    }
  }

  depends_on = [aws_lambda_permission.timesync-lambda-permission-allow-invoke-notification_team]
}

resource "aws_lambda_function_event_invoke_config" "notification_success_destination" {
  function_name           = aws_lambda_function.timesync-lambda-function-notification_team.arn
  qualifier               = "$LATEST"
  maximum_retry_attempts  = 0

  destination_config {
    on_success {
      destination = var.timesync-sns-topico-information-arn
    }
  }

  # depends_on = [aws_lambda_permission.allow_lambda_notification_to_publish_sns]
}

resource "aws_lambda_layer_version" "mysql_connector_layer" {
  filename          = "${path.module}/code/mysql_connector_python.zip"
  layer_name        = "mysql-connector-python-layer"
  compatible_runtimes = ["python3.11"]
}

resource "aws_lambda_function" "process_raw_lambda" {
  filename         = "${path.module}/code/dummy_lambda.zip"
  function_name    = "timesync-etl-function-841051091018312111099"
  role             = "arn:aws:iam::${var.account_id}:role/LabRole"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60

  environment {
    variables = {
      RAW_BUCKET = var.raw_bucket_name
      SNS_TOPIC_ARN = var.raw_topic_arn
    }
  }

  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python313:1"
  ]

}

resource "aws_lambda_function" "process_trusted_lambda" {
  filename         = "${path.module}/code/dummy_lambda.zip"
  function_name    = "timesync-insert-functions-841051091018312111099"
  role             = "arn:aws:iam::${var.account_id}:role/LabRole"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60

  environment {
    variables = {
      TRUSTED_BUCKET = var.trusted_bucket_name
    }
  }

  layers = [
    aws_lambda_layer_version.mysql_connector_layer.arn
  ]
}

resource "aws_lambda_function" "process_backup_lambda" {
  filename         = "${path.module}/code/dummy_lambda.zip"
  function_name    = "timesync-backup-function-841051091018312111099"
  role             = "arn:aws:iam::${var.account_id}:role/LabRole"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60

  environment {
    variables = {
      BACKUP_BUCKET = var.backup_bucket_name
    }
  }
}

resource "aws_s3_bucket_notification" "raw_trigger" {
  bucket = var.raw_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_raw_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke_raw]
}

resource "aws_s3_bucket_notification" "backup_trigger" {
  bucket = var.backup_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_backup_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke_backup]
}


resource "aws_s3_bucket_notification" "trusted_trigger" {
  bucket = var.trusted_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_trusted_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".csv"
  }
  
  depends_on = [aws_lambda_permission.allow_s3_to_invoke_trusted]
}

resource "aws_lambda_permission" "allow_s3_to_invoke_raw" {
  statement_id  = "AllowExecutionFromS3Raw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_raw_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.raw_bucket_name}"
}

resource "aws_lambda_permission" "allow_s3_to_invoke_trusted" {
  statement_id  = "AllowExecutionFromS3Trusted"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_trusted_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.trusted_bucket_name}"
}

resource "aws_lambda_permission" "allow_s3_to_invoke_backup" {
  statement_id  = "AllowExecutionFromS3Trusted"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_backup_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.backup_bucket_name}"
}

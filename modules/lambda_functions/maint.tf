
resource "random_id" "lambda_suffix" {
  byte_length = 4
}

resource "aws_lambda_function" "process_raw_lambda" {
  filename         = "${path.module}/code/lambda_raw_function.zip"
  function_name    = "ProcessRawLambda-${random_id.lambda_suffix.hex}"
  role             = "arn:aws:iam::${var.account_id}:role/LabRole"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      RAW_BUCKET = var.raw_bucket_name
    }
  }
}

resource "aws_lambda_function" "process_trusted_lambda" {
  filename         = "${path.module}/code/lambda_trusted_function.zip"
  function_name    = "ProcessTrustedLambda-${random_id.lambda_suffix.hex}"
  role             = "arn:aws:iam::${var.account_id}:role/LabRole"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      TRUSTED_BUCKET = var.trusted_bucket_name
      MYSQL_HOST     = var.mysql_host
      MYSQL_USER     = var.mysql_user
      MYSQL_PASSWORD = var.mysql_password
      MYSQL_DB       = var.mysql_db
    }
  }
}

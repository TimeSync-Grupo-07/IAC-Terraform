# Camada para conector MySQL
resource "aws_lambda_layer_version" "timesync-lambda-layer-mysql_connector" {
  filename            = "./modules/lambda_functions/code/mysql_connector_python.zip"
  layer_name          = "timesync-lambda-layer-mysql_connector"
  compatible_runtimes = ["python3.11"]
}

# 1. Lambda para backup - ativa quando bucket_raw recebe dados
resource "aws_lambda_function" "timesync-lambda-function-backup" {
  filename      = "./modules/lambda_functions/code/codigo_padrao.zip"
  function_name = "timesync-backup-function"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      BACKUP_BUCKET = var.timesync-bucket-backup-bucket_name
      RAW_BUCKET    = var.timesync-bucket-raw-bucket_name
    }
  }
}

# 2. Lambda para primeiro tratamento - ativa quando bucket_raw recebe dados
resource "aws_lambda_function" "timesync-lambda-function-process-raw" {
  filename      = "./modules/lambda_functions/code/codigo_padrao.zip"
  function_name = "timesync-process-raw-function"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 120  # Aumentado para processamento
  memory_size   = 512  # Aumentado para processamento

  environment {
    variables = {
      RAW_BUCKET = var.timesync-bucket-raw-bucket_name
      NEXT_LAMBDA_ARN = aws_lambda_function.timesync-lambda-function-process-step2.arn
    }
  }

  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python313:1"
  ]
}

# 3. Lambda para segundo tratamento - chamada pela lambda anterior
resource "aws_lambda_function" "timesync-lambda-function-process-step2" {
  filename      = "./modules/lambda_functions/code/codigo_padrao.zip"
  function_name = "timesync-process-step2-function"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 120  # Aumentado para processamento
  memory_size   = 512  # Aumentado para processamento

  environment {
    variables = {
      NEXT_LAMBDA_ARN = aws_lambda_function.timesync-lambda-function-process-trusted.arn
    }
  }
}

# 4. Lambda para envio ao trusted - chamada pela lambda anterior
resource "aws_lambda_function" "timesync-lambda-function-process-trusted" {
  filename      = "./modules/lambda_functions/code/codigo_padrao.zip"
  function_name = "timesync-process-trusted-function"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      TRUSTED_BUCKET = var.timesync-bucket-trusted-bucket_name
    }
  }
}

# 5. Lambda para inserção no MySQL - ativa quando bucket_trusted recebe dados
resource "aws_lambda_function" "timesync-lambda-function-insert-db" {
  filename      = "./modules/lambda_functions/code/codigo_padrao.zip"
  function_name = "timesync-insert-db-function"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 120
  memory_size   = 512

  environment {
    variables = {
      TRUSTED_BUCKET = var.timesync-bucket-trusted-bucket_name
      DB_HOST = var.timesync-db-host
      DB_USER = var.timesync-db-user
      DB_PASS = var.timesync-db-password
      DB_NAME = var.timesync-db-name
    }
  }

  layers = [
    aws_lambda_layer_version.timesync-lambda-layer-mysql_connector.arn
  ]
}

resource "aws_lambda_permission" "timesync-lambda-permission-backup" {
  statement_id  = "AllowExecutionFromS3RawBackup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timesync-lambda-function-backup.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.timesync-bucket-raw-bucket_name}"
}

resource "aws_lambda_permission" "timesync-lambda-permission-process-raw" {
  statement_id  = "AllowExecutionFromS3RawProcess"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timesync-lambda-function-process-raw.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.timesync-bucket-raw-bucket_name}"
}

resource "aws_lambda_permission" "timesync-lambda-permission-step2" {
  statement_id  = "AllowExecutionFromLambdaProcessRaw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timesync-lambda-function-process-step2.function_name
  principal     = "lambda.amazonaws.com"
  source_arn    = aws_lambda_function.timesync-lambda-function-process-raw.arn
}

resource "aws_lambda_permission" "timesync-lambda-permission-trusted" {
  statement_id  = "AllowExecutionFromLambdaStep2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timesync-lambda-function-process-trusted.function_name
  principal     = "lambda.amazonaws.com"
  source_arn    = aws_lambda_function.timesync-lambda-function-process-step2.arn
}

resource "aws_lambda_permission" "timesync-lambda-permission-insert-db" {
  statement_id  = "AllowExecutionFromS3Trusted"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timesync-lambda-function-insert-db.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.timesync-bucket-trusted-bucket_name}"
}

resource "aws_s3_bucket_notification" "timesync-lambda-trigger-backup" {
  bucket = var.timesync-bucket-raw-bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.timesync-lambda-function-backup.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.timesync-lambda-permission-backup]
}

resource "aws_s3_bucket_notification" "timesync-lambda-trigger-process-raw" {
  bucket = var.timesync-bucket-raw-bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.timesync-lambda-function-process-raw.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.timesync-lambda-permission-process-raw]
}

resource "aws_s3_bucket_notification" "timesync-lambda-trigger-insert-db" {
  bucket = var.timesync-bucket-trusted-bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.timesync-lambda-function-insert-db.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.timesync-lambda-permission-insert-db]
}

resource "aws_lambda_function_event_invoke_config" "timesync-lambda-destination-process-raw" {
  function_name          = aws_lambda_function.timesync-lambda-function-process-raw.function_name
  qualifier              = "$LATEST"
  maximum_retry_attempts = 0

  destination_config {
    on_success {
      destination = aws_lambda_function.timesync-lambda-function-process-step2.arn
    }
  }
}

resource "aws_lambda_function_event_invoke_config" "timesync-lambda-destination-step2" {
  function_name          = aws_lambda_function.timesync-lambda-function-process-step2.function_name
  qualifier              = "$LATEST"
  maximum_retry_attempts = 0

  destination_config {
    on_success {
      destination = aws_lambda_function.timesync-lambda-function-process-trusted.arn
    }
  }
}
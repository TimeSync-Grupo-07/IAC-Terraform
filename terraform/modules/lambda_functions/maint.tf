# Camada para conector MySQL
resource "aws_lambda_layer_version" "timesync_lambda_layer_mysql_connector" {
  filename            = "./modules/lambda_functions/code/mysql_connector_python.zip"
  layer_name          = "timesync-lambda-layer-mysql-connector"
  compatible_runtimes = ["python3.11"]
}

# 1. Lambda - Backup (raw -> backup)
resource "aws_lambda_function" "lambda_backup" {
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

# 2. Lambda - Raw -> Trusted
resource "aws_lambda_function" "lambda_raw_to_trusted" {
  filename      = "./modules/lambda_functions/code/codigo_padrao.zip"
  function_name = "timesync-raw-to-trusted-function"
  role          = "arn:aws:iam::${var.timesync-administrador-conta-id}:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      RAW_BUCKET     = var.timesync-bucket-raw-bucket_name
      TRUSTED_BUCKET = var.timesync-bucket-trusted-bucket_name
    }
  }
}

# 3. Lambda - Trusted -> MySQL
resource "aws_lambda_function" "lambda_insert_db" {
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
      DB_HOST        = var.timesync-db-host
      DB_USER        = var.timesync-db-user
      DB_PASS        = var.timesync-db-password
      DB_NAME        = var.timesync-db-name
    }
  }

  layers = [
    aws_lambda_layer_version.timesync_lambda_layer_mysql_connector.arn
  ]
}

# Permissão RAW -> Backup
resource "aws_lambda_permission" "allow_raw_backup" {
  statement_id  = "AllowExecutionFromS3RawBackup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_backup.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.timesync-bucket-raw-bucket_name}"
}

# Permissão RAW -> RawToTrusted
resource "aws_lambda_permission" "allow_raw_to_trusted" {
  statement_id  = "AllowExecutionFromS3RawToTrusted"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_raw_to_trusted.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.timesync-bucket-raw-bucket_name}"
}

# Permissão TRUSTED -> InsertDB
resource "aws_lambda_permission" "allow_trusted_insert_db" {
  statement_id  = "AllowExecutionFromS3TrustedInsertDB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_insert_db.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.timesync-bucket-trusted-bucket_name}"
}

# RAW -> Backup
resource "aws_s3_bucket_notification" "trigger_raw_backup" {
  bucket = var.timesync-bucket-raw-bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_backup.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_raw_backup]
}

# RAW -> Trusted
resource "aws_s3_bucket_notification" "trigger_raw_to_trusted" {
  bucket = var.timesync-bucket-raw-bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_raw_to_trusted.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_raw_to_trusted]
}

# TRUSTED -> Insert DB
resource "aws_s3_bucket_notification" "trigger_trusted_insert_db" {
  bucket = var.timesync-bucket-trusted-bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_insert_db.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_trusted_insert_db]
}


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

  environment {
    variables = {
      TRUSTED_BUCKET = var.trusted_bucket_name
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

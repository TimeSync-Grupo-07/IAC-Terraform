output "lambda_raw_function_name" {
  value = aws_lambda_function.process_raw_lambda.function_name
}

output "lambda_trusted_function_name" {
  value = aws_lambda_function.process_trusted_lambda.function_name
}

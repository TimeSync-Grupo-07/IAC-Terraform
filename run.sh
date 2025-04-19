#!/bin/bash

set -e

echo "🔧 Carregando variáveis de ambiente do .env"
export $(grep -v '^#' .env | xargs)

echo "📦 Clonando repositório com o código das Lambdas (branch main)..."
rm -rf temp_lambda_code
git clone --branch main https://github.com/seu-usuario/lambda-functions-code.git temp_lambda_code

echo "🗜️ Empacotando lambda_raw_function..."
mkdir -p modules/lambda_functions/code
cd temp_lambda_code/lambda_raw_function
zip -r ../../../modules/lambda_functions/code/lambda_raw_function.zip .
cd ../../..

echo "🗜️ Empacotando lambda_trusted_function..."
cd temp_lambda_code/lambda_trusted_function
zip -r ../../../modules/lambda_functions/code/lambda_trusted_function.zip .
cd ../../..

echo "🧹 Limpando arquivos temporários..."
rm -rf temp_lambda_code

echo "🚀 Executando Terraform com as variáveis..."

terraform "$@" \
  -var="email_address=$EMAIL_ADDRESS" \
  -var="mysql_user=$MYSQL_USER" \
  -var="mysql_password=$MYSQL_PASSWORD" \
  -var="mysql_db=$MYSQL_DB" \
  -var="account_id=$ACCOUNT_ID"

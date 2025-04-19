#!/bin/bash

set -e

export $(grep -v '^#' .env | xargs)
echo "🔄 Empacotando funções Lambda via Docker..."
./deploy_lambda.sh

echo "🚀 Executando Terraform..."
terraform "$@" \
  -var="email_address=$EMAIL_ADDRESS" \
  -var="mysql_user=$MYSQL_USER" \
  -var="mysql_password=$MYSQL_PASSWORD" \
  -var="mysql_db=$MYSQL_DB" \
  -var="account_id=$ACCOUNT_ID"

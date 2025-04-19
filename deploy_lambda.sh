#!/bin/bash

set -e

LAMBDA_REPO_URL="https://github.com/TimeSync-Grupo-07/Lambda_functions-Python.git" # 🔁 Substitua pela URL real
LAMBDA_REPO_BRANCH="main"
LAMBDA_LOCAL_DIR="temp_lambda_functions"
LAMBDA_NAMES=("lambda_raw_function" "lambda_trusted_function")
ZIP_OUTPUT_DIR="modules/lambda_functions/code"

echo "📥 Clonando repositório de funções Lambda..."
rm -rf $LAMBDA_LOCAL_DIR
git clone --depth 1 --branch $LAMBDA_REPO_BRANCH $LAMBDA_REPO_URL $LAMBDA_LOCAL_DIR

mkdir -p $ZIP_OUTPUT_DIR
mkdir -p ./packages

for FUNCTION in "${LAMBDA_NAMES[@]}"; do
  echo "🔧 Empacotando $FUNCTION via Docker..."

  docker build \
    -f Dockerfile.lambda \
    --build-arg FUNCTION_DIR=$LAMBDA_LOCAL_DIR/$FUNCTION \
    --build-arg ZIP_NAME=$FUNCTION.zip \
    -t lambda-packager-$FUNCTION .

  CONTAINER_ID=$(docker create lambda-packager-$FUNCTION)

  docker cp $CONTAINER_ID:/out/$FUNCTION.zip $ZIP_OUTPUT_DIR/$FUNCTION.zip
  docker cp $CONTAINER_ID:/out/$FUNCTION.zip ./packages/$FUNCTION.zip

  docker rm $CONTAINER_ID
  docker image rm lambda-packager-$FUNCTION

  echo "✅ $FUNCTION empacotado com sucesso!"
done

rm -rf $LAMBDA_LOCAL_DIR

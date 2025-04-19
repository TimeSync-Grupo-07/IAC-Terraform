#!/bin/bash

set -e

# Lista de funções lambda a empacotar
FUNCTIONS=("lambda_raw_function" "lambda_trusted_function")

for FUNCTION in "${FUNCTIONS[@]}"; do
  echo "Empacotando $FUNCTION via Docker..."

  docker build \
    -f Dockerfile.lambda \
    --build-arg FUNCTION_DIR=$FUNCTION \
    -t lambda-packager-$FUNCTION .

  CONTAINER_ID=$(docker create lambda-packager-$FUNCTION)

  docker cp $CONTAINER_ID:/app/$FUNCTION.zip terraform/modules/lambda_functions/code/$FUNCTION.zip
  docker rm $CONTAINER_ID
  docker image rm lambda-packager-$FUNCTION

  echo "$FUNCTION empacotado com sucesso!"
done

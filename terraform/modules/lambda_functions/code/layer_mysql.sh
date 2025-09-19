#!/bin/bash

set -e

LAYER_NAME="mysql_connector_python"
PYTHON_VERSION="python3.11"

# Limpa diretórios antigos
rm -rf build
mkdir -p build/python

# Instala a biblioteca na pasta correta
pip3 install mysql-connector-python -t build/python

# Cria o zip
cd build
zip -r ../${LAYER_NAME}.zip python
cd ..

rm -rf build/

echo "Layer ${LAYER_NAME}.zip criada com sucesso!"

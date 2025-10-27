#!/bin/bash

cd ansible/

rm -f aws.yml

cd inventory/

rm *.json

cd ..

cd ..

cd terraform/

terraform destroy -auto-approve
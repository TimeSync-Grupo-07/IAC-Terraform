#!/bin/bash

cd terraform/

terraform init

terraform apply -auto-approve

terraform output -json bastion_ip > ../ansible/inventory/bastion.json

terraform output -json public_hosts > ../ansible/inventory/public_hosts.json

terraform output -json private_hosts > ../ansible/inventory/private_hosts.json

cd ..

cd ansible/

python3 inventory/generate_inventory.py

ansible-playbook -i aws.yml playbooks/config.yml
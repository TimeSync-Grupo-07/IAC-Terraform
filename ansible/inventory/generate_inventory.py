import json
import yaml

def load_hosts(path):
    with open(path) as f:
        data = json.load(f)
        # Se for dict (vem com "value"), pega só o value
        if isinstance(data, dict) and "value" in data:
            return data["value"]
        # Se já for lista, retorna direto
        return data

def load_bastion(path):
    with open(path) as f:
        data = json.load(f)
        if isinstance(data, dict) and "value" in data:
            return data["value"]
        return data

# Carregar arquivos
public_hosts = load_hosts("inventory/public_hosts.json")
private_hosts = load_hosts("inventory/private_hosts.json")
bastion_ip = load_bastion("inventory/bastion.json")

# Estrutura do inventário Ansible
inventory = {
    "all": {
        "children": {
            "public": {
                "hosts": {
                    host["name"]: {
                        "ansible_host": host["public_ip"],
                        "ansible_user": "ubuntu",   # ajuste se sua AMI usa ec2-user
                        "ansible_ssh_private_key_file": host["key_file"]
                    }
                    for host in public_hosts
                }
            },
            "private": {
                "hosts": {
                    host["name"]: {
                        "ansible_host": host["private_ip"],
                        "ansible_user": "ubuntu",
                        "ansible_ssh_private_key_file": host["key_file"],
                        "ansible_ssh_common_args": (
                            f"-o ProxyCommand='ssh -W %h:%p -q -i {public_hosts[0]['key_file']} ubuntu@{bastion_ip}'"
                        )
                    }
                    for host in private_hosts
                }
            }
        }
    }
}

# Salvar inventário no formato YAML
with open("aws.yml", "w") as f:
    yaml.dump(inventory, f, sort_keys=False)

print("✅ Inventário aws.yml gerado com sucesso!")

# uprightlab — Semaphore Setup

This file documents the manual steps to configure Semaphore. In future this is likely to be moved to Terraform/OpenTofu.

For now, as I'm interested in learning these steps, will run through the setup manually.

1. Output a copy of the Semaphore public key `cat ~/.ssh/semaphore_service_key.pub`.
1. Add the key to GitHub at https://github.com/uprightvinyl/homelab/settings/keys. Leave Allow write access un-ticked.
1. Open Semaphore at http://10.0.10.10:3000/ and create a new project called "uprightlab".
1. Add the Semaphore private key as a service key under Key Store.
1. Add git@github.com:uprightvinyl/homelab.git as a repository.
1. Add a new Inventory using ansible/inventory/hosts.yaml.
1. Add a Variable Group called `external-secrets`, with a Secret environment variable called CLOUDFLARE_TUNNEL_TOKEN, add the CloudFlare Tunnel Token as the value, which is stored in 1Password.
1. Add a key to Key Store called Ansible Vault Password, of Type Login with Password. Add the Ansible Vault password from 1Password.
1. Add a new task template with a playbook path of ansible/playbooks/waddle.yaml. Configure it as follows:
    - Name: Configure waddle
    - Path: ansible/playbooks/waddle.yaml
    - Inventory: uprightlab
    - Repository: homelab
    - Variable Groups: external-secrets
    - Vaults:
        - Type: Password
        - Vault Password: Ansible Vault Password
1. Run the Task, it should run to completion without making any changes. 

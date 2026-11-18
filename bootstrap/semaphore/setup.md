# uprightlab — Semaphore Setup

This file documents the manual steps to configure Semaphore. In future this is likely to be moved to Terraform/OpenTofu.

For now, as I'm interested in learning these steps, will run through the setup manually.

1. Output a copy of the Semaphore public key `cat ~/.ssh/semaphore_service_key.pub`.
1. Add the key to GitHub at https://github.com/uprightvinyl/homelab/settings/keys. Leave Allow write access un-ticked.
1. Open Semaphore at http://10.0.10.10:3000/ and create a new project called "uprightlab".
1. Add the Semaphore ed25519 private key as a service key under Key Store. `cat ~/.ssh/semaphore_service_key`.
1. Add the Semaphore RSA private key as a service key under Key Store. `cat ~/.ssh/semaphore_rsa_key`.
1. Add git@github.com:uprightvinyl/homelab.git as a repository.
1. Add two Inventories, both using ansible/inventory/hosts.yaml. Semaphore attaches the SSH key to the inventory rather than the template, so hosts needing different keys need separate inventories:
    - **uprightlab** — uses the ed25519 service key. Used for most hosts, including waddle and coo.
    - **uprightlab-rsa** — uses the RSA service key, for bandee (the SG350 only supports RSA keys).
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
1. Add a task template for bandee, configured as follows:
    - Name: Configure bandee
    - Path: ansible/playbooks/bandee.yaml
    - Inventory: uprightlab-rsa
    - Repository: homelab
    - Vaults:
        - Type: Password
        - Vault Password: Ansible Vault Password
1. Run the Task, it should run to completion without making any changes. Don't run it in check mode: `community.ciscosmb.command` doesn't support check mode, so the playbook's read tasks are skipped and the run fails.
1. Add a task template for coo, configured as follows:
    - Name: Configure coo
    - Path: ansible/playbooks/coo.yaml
    - Inventory: uprightlab
    - Repository: homelab
    - Vaults:
        - Type: Password
        - Vault Password: Ansible Vault Password
1. Run the Task. Semaphore first installs `community.network` from `ansible/playbooks/collections/requirements.yml`, as it is no longer part of the `ansible` package. The run should complete without making any changes.

# uprightlab — Workstation Setup

This file documents manual setup steps required on the MacBook workstation that cannot be automated via the Brewfile.

- An alias needs adding to use `rpi-imager`, as the Pi Imager installs as macOS app, not a CLI tool. That can be done with the following command:

    `echo "alias rpi-imager='/Applications/Raspberry\ Pi\ Imager.app/Contents/MacOS/rpi-imager'" >> ~/.zshrc`

    `source ~/.zshrc`

- For access to bandee, as it only supports RSA keys, the following needs to be carried out:

    1. Generate an rsa key pair `ssh-keygen -t rsa -b 4096`. Note: Use a passphrase and store it in 1Password.
    1. Add the following to ~/.ssh/config to allow the older ssh-rsa algorithm, just for bandee.

    ```
    Host 192.168.4.254
        HostKeyAlgorithms +ssh-rsa
        PubkeyAcceptedAlgorithms +ssh-rsa
    ```

- for access from the Eero network (192.168.4.0/22) during initial setup, we'll need a static route in place for waddle. Note, when Cloudflare is used, this route will automatically get overwritten.

    ```
    sudo route add -net 10.0.10.0/24 192.168.4.254
    ```

- Create Ansible vault file containing variables from the Docker Compose file at [../../docker/waddle/docker-compose.yaml}(../../docker/waddle/docker-compose.yaml).

- Run `ansible-galaxy collection install -r requirements.yaml` prior to running the playbook for waddle

- Generate a service key for Semaphore. Don't set a passphrase. Copy the public key to the ansible folder so it can be used when setting up hosts that Semaphore will need access to.

    ```
    ssh-keygen -t ed25519 -C "semaphore@waddle.lab.uprightlab.com" -f ~/.ssh/semaphore_service_key
    cp ~/.ssh/semaphore_service_key.pub /ansible/files/semaphore_service_key.pub
    ```
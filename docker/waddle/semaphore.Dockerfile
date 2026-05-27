# Ideally we'd use the semaphore image without modification. However, we need
# to connect to an older Cisco switch, which does not support modern SSH
# features. To work around this, we need to install a compatible SSH library.
# This Dockerfile modifies the base image to include the necessary dependencies.

FROM semaphoreui/semaphore:latest

# This image has no 'semaphore' user; it runs as root.
USER root

# Ansible reaches the switch over SSH using the ansible-pylibssh library. pip
# has no ready-made build of that library for this image's Linux (Alpine), so it 
# compiles it from source. That needs build tools (gcc etc.) plus libssh. We install
# those, build the library, then remove the build tools to keep the image small
# — but keep libssh, which the finished library still needs to run.
RUN apk add --no-cache --virtual .build gcc musl-dev python3-dev libssh-dev \
 && apk add --no-cache libssh \
 && pip install --break-system-packages ansible-pylibssh \
 && apk del .build

# Allow bandee's legacy ssh-rsa host key (Cisco SG350). libssh looks for these
# settings in the ssh config of whoever runs Ansible inside this container
# (root here, so /root/.ssh/config), plus the global /etc/ssh/ssh_config.
RUN install -d -m 700 /root/.ssh \
 && install -d -m 755 /etc/ssh \
 && printf 'Host 192.168.4.254\n    HostKeyAlgorithms +ssh-rsa\n    PubkeyAcceptedAlgorithms +ssh-rsa\n' \
      | tee /root/.ssh/config >> /etc/ssh/ssh_config \
 && chmod 600 /root/.ssh/config
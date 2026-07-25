#cloud-config
package_update: true
package_upgrade: true

packages:
  - vim
  - curl
  - wget
  - git
  - net-tools
  - htop
  - ca-certificates
  - gnupg
  - lsb-release
  - python3
  - python3-pip
  - apt-transport-https
  - qemu-guest-agent

hostname: ${hostname}
fqdn: ${hostname}.local
preserve_hostname: false

users:
  - name: root
    ssh_authorized_keys:
      - ${ssh_public_key}

  - name: ansible
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ssh_public_key}
    shell: /bin/bash

ssh_pwauth: false
disable_root: false

runcmd:
  - hostnamectl set-hostname ${hostname}
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - systemctl restart ssh
  - echo "Kubernetes cluster node initialized" > /var/log/k8s-init.log

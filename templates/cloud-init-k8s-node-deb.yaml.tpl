#cloud-config
users:
  - name: ${useros}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ${adm_pub_key}
package_update: true
package_upgrade: true
packages:
  # Update the apt package index and install packages needed to use the Docker and Kubernetes apt repositories over HTTPS
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - lsb-release
  - snap
  - containerd

power_state:
 delay: "+1"
 mode: reboot
 message: Reboot
 timeout: 1
 condition: True

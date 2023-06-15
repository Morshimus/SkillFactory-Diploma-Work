#cloud-config
users:
  - name: ${useros}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ${adm_pub_key}
runcmd:
  - source /etc/os-release && curl -fsSL https://download.docker.com/linux/$ID/gpg |  apt-key add && echo "deb [arch=amd64] https://download.docker.com/linux/$ID $VERSION_CODENAME stable" |  tee /etc/apt/sources.list.d/docker.list
package_update: true
package_upgrade: true
packages:
  - docker
  - docker-compose     
runcmd:
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker ${useros}
  
power_state:
 delay: "+1"
 mode: reboot
 message: Reboot
 timeout: 1
 condition: True
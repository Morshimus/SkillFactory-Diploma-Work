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
  - apt-transport-https
  - ca-certificates
  - curl
runcmd:
  - curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
  - source /etc/os-release && curl -fsSL https://download.docker.com/linux/$ID/gpg |  apt-key add && echo "deb [arch=amd64] https://download.docker.com/linux/$ID $VERSION_CODENAME stable" |  tee /etc/apt/sources.list.d/docker.list
package_update: true
packages:
  - containerd
  - kubelet
  - kubeadm
  - kubectl
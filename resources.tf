####################################################
#                    VPC                           #
#                                                  #
####################################################


resource "yandex_vpc_network" "morsh-network" {
  name = var.network_name_yandex

}



resource "yandex_vpc_subnet" "morsh-subnet-a" {
  name           = var.subnet_a_name_yandex
  description    = var.subnet_a_description_yandex
  v4_cidr_blocks = var.subnet_a_v4_cidr_blocks_yandex
  zone           = var.zone_yandex_a
  network_id     = yandex_vpc_network.morsh-network.id

}

####################################################
#             Compute Instances                    #
#                                                  #
####################################################

module "k8s-node-control-plane" {
  source = "git::https://github.com/Morshimus/yandex-cloud-instance-module?ref=tags/1.1.2"

  for_each = var.k8s_node_cp.name

  source_image_family = "ubuntu-2204-lts"
  boot_disk = {
    initialize_params = {
      size = var.os_disk_size
      type = "network-ssd"
    }
  }

  network_interface = [
    {
      subnet_id = yandex_vpc_subnet.morsh-subnet-a.id
      nat       = true
    }
  ]


  prefix      = each.value
  postfix     = each.key
  vm_vcpu_qty = 4
  vm_ram_qty  = 8
  cloud-init  = local.cloud-init-k8s-node-deb
  #cloud-init = local.cloud-init
  useros      = var.useros
  adm_prv_key = tls_private_key.key.private_key_openssh

}

module "k8s-node-worker" {
  source = "git::https://github.com/Morshimus/yandex-cloud-instance-module?ref=tags/1.1.2"

  for_each = var.k8s_node_worker.name

  source_image_family = "ubuntu-2204-lts"
  boot_disk = {
    initialize_params = {
      size = var.os_disk_size
      type = "network-ssd"
    }
  }

  network_interface = [
    {
      subnet_id = yandex_vpc_subnet.morsh-subnet-a.id
      nat       = true
    }
  ]


  prefix      = each.value
  postfix     = each.key
  vm_vcpu_qty = 4
  vm_ram_qty  = 8
  cloud-init  = local.cloud-init-k8s-node-deb
  #cloud-init = local.cloud-init
  useros      = var.useros
  adm_prv_key = tls_private_key.key.private_key_openssh
}

module "k8s-outside-servers" {
  source = "git::https://github.com/Morshimus/yandex-cloud-instance-module?ref=tags/1.1.2"

  for_each = var.k8s_outside_srv.name

  source_image_family = "ubuntu-2204-lts"
  boot_disk = {
    initialize_params = {
      size = var.os_disk_size
      type = "network-ssd"
    }
  }

  network_interface = [
    {
      subnet_id = yandex_vpc_subnet.morsh-subnet-a.id
      nat       = true
    }
  ]


  prefix      = each.value
  postfix     = each.key
  vm_vcpu_qty = 4
  vm_ram_qty  = 8
  cloud-init  = local.cloud-init-ci-cd-monitor-deb
  useros      = var.useros
  adm_prv_key = tls_private_key.key.private_key_openssh
}


####################################################
#                 Keys                             #
#                                                  #
####################################################

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

####################################################
#                 Local Files                      #
#                                                  #
####################################################

resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "${path.module}/SSH_KEY_FINAL"
}

resource "local_file" "yandex_inventory" {
  content  = local.ansible_template
  filename = "${path.module}/inventory/sf-cluster/inventory.ini"

  provisioner "local-exec" {
    command     = <<EOF
     Wait-Event -Timeout 120;
     wsl -e /bin/bash -c 'cp .vault_pass_diploma  ~/.vault_pass_diploma ; chmod 0600 ~/.vault_pass_diploma';
     wsl -e /bin/bash -c 'cp SSH_KEY_FINAL  ~/.ssh/SSH_KEY_FINAL ; chmod 0600 ~/.ssh/SSH_KEY_FINAL';
     . ./actions.ps1;
     kubespray; 
     $ConnectionConf= gc $env:KUBECONFIG;
     $ConnectionConf=$ConnectionConf  -replace "${lookup(local.k8s_cluster_cp_ip_priv, "ip", 0)}", "${lookup(local.k8s_cluster_cp_ip_pub, "ip", 0)}"; 
     $ConnectionConf | Set-Content -Encoding UTF8 $env:KUBECONFIG; 
     flux_bootstrap
    EOF
    interpreter = ["powershell.exe", "-NoProfile", "-c"]

    environment = {
      GITHUB_TOKEN = data.ansiblevault_path.github-token.value
      GITHUB_USER  = data.ansiblevault_path.github-user.value
    }
  }
}
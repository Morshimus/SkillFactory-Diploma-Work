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
    source = "git::https://github.com/Morshimus/yandex-cloud-instance-module?ref=tags/1.0.0"

#  for_each = toset(["001", "002", "003"])

  source_image_family = "ubuntu-22-04-lts"
  boot_disk = {
    initialize_params = {
      size = var.os_disk_size
      type = "network-ssd"
    }
  }

  network_interface = [
    {
      subnet_id      = yandex_vpc_subnet.morsh-subnet-a.id
      nat            = true
  #    nat_ip_address = each.key == "001" ? yandex_vpc_address.morsh-addr-pub_1.external_ipv4_address[0].address : each.key == "002" ? yandex_vpc_address.morsh-addr-pub_2.external_ipv4_address[0].address : yandex_vpc_address.morsh-addr-pub_3.external_ipv4_address[0].address
    }
  ]


  prefix      = "k8s-polar-cp"
  postfix     = each.key
  vm_vcpu_qty = 4
  vm_ram_qty  = 8
  adm_pub_key = tls_private_key.key.public_key_openssh
  useros      = var.useros
}

module "k8s-node-worker" {
    source = "git::https://github.com/Morshimus/yandex-cloud-instance-module?ref=tags/1.0.0"

#  for_each = toset(["001", "002", "003"])

  source_image_family = "ubuntu-22-04-lts"
  boot_disk = {
    initialize_params = {
      size = var.os_disk_size
      type = "network-ssd"
    }
  }

  network_interface = [
    {
      subnet_id      = yandex_vpc_subnet.morsh-subnet-a.id
      nat            = true
  #    nat_ip_address = each.key == "001" ? yandex_vpc_address.morsh-addr-pub_1.external_ipv4_address[0].address : each.key == "002" ? yandex_vpc_address.morsh-addr-pub_2.external_ipv4_address[0].address : yandex_vpc_address.morsh-addr-pub_3.external_ipv4_address[0].address
    }
  ]


  prefix      = "k8s-polar-worker"
  postfix     = each.key
  vm_vcpu_qty = 4
  vm_ram_qty  = 8
  adm_pub_key = tls_private_key.key.public_key_openssh
  useros      = var.useros
}

module "k8s-outside-servers" {
    source = "git::https://github.com/Morshimus/yandex-cloud-instance-module?ref=tags/1.0.0"

 # for_each = toset(["001", "002", "003"])

  source_image_family = "ubuntu-22-04-lts"
  boot_disk = {
    initialize_params = {
      size = var.os_disk_size
      type = "network-ssd"
    }
  }

  network_interface = [
    {
      subnet_id      = yandex_vpc_subnet.morsh-subnet-a.id
      nat            = true
  #    nat_ip_address = each.key == "001" ? yandex_vpc_address.morsh-addr-pub_1.external_ipv4_address[0].address : each.key == "002" ? yandex_vpc_address.morsh-addr-pub_2.external_ipv4_address[0].address : yandex_vpc_address.morsh-addr-pub_3.external_ipv4_address[0].address
    }
  ]


  prefix      = "k8s-external-srv"
  postfix     = each.key
  vm_vcpu_qty = 4
  vm_ram_qty  = 8
  adm_pub_key = tls_private_key.key.public_key_openssh
  useros      = var.useros
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
  filename = "${path.module}/SSH_KEY_42"
}
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

resource "yandex_vpc_address" "morsh-addr-pub" {
  name = "ipv4 pub for alb"
  external_ipv4_address {
    zone_id = var.zone_yandex_a
  }
}

####################################################
#                    DNS                           #
#                                                  #
####################################################

resource "yandex_dns_zone" "dns_pub" {
  name        = var.dns_name_pub
  zone             = var.dns_zone_pub
  public           = true
  description = "Public DNS zone for project"
}

resource "yandex_dns_recordset" "polar-net-ru" {
  count   = yandex_cm_certificate.polar-net-ru.managed[0].challenge_count
  zone_id = yandex_dns_zone.dns_pub.id
  name    = yandex_cm_certificate.polar-net-ru.challenges[count.index].dns_name
  type    = yandex_cm_certificate.polar-net-ru.challenges[count.index].dns_type
  data    = [yandex_cm_certificate.polar-net-ru.challenges[count.index].dns_value]
  ttl     = 60

}

resource "yandex_dns_recordset" "k8s" {
  zone_id = yandex_dns_zone.dns_pub.id
  name    = "k8s.${var.dns_zone_pub}"
  type    = "A"
  ttl     = 86400
  data    = [lookup(local.k8s_cluster_cp_ip_pub, "ip", "10.1.0.1")]
}

resource "yandex_dns_recordset" "jenkins" {
  zone_id = yandex_dns_zone.dns_pub.id
  name    = "jenkins.${var.dns_zone_pub}"
  type    = "A"
  ttl     = 86400
  data    = [lookup(module.internet-alb-project.external_ip_address_alb, "external", "10.0.0.1")[0].0[0]]
}

resource "yandex_dns_recordset" "grafana" {
  zone_id = yandex_dns_zone.dns_pub.id
  name    = "grafana.${var.dns_zone_pub}"
  type    = "A"
  ttl     = 86400
  data    = [lookup(module.internet-alb-project.external_ip_address_alb, "external", "10.0.0.1")[0].0[0]]
}

resource "yandex_dns_recordset" "skillfactory" {
  zone_id = yandex_dns_zone.dns_pub.id
  name    = "skillfactory.${var.dns_zone_pub}"
  type    = "A"
  ttl     = 86400
  data    = [lookup(module.internet-alb-project.external_ip_address_alb, "external", "10.0.0.1")[0].0[0]]
}

####################################################
#           Application Load-Balancers             #
#                                                  #
####################################################

module "internet-alb-project" {

  source = "git::https://github.com/Morshimus/terraform-yandex-cloud-application-load-balancer-module?ref=tags/1.1.1"
  name = "internet-edge"
  description = "Internet edge to K8S ingress and servers"
  network_id = yandex_vpc_network.morsh-network.id
  region_id = "ru-central1"
  log_options = []

  allocation_policy = [{
    location = [{
      zone_id = var.zone_yandex_a
      subnet_id = yandex_vpc_subnet.morsh-subnet-a.id
      disable_traffic = false
    }]
  }]

  listener = [{
    name = "external"
    endpoint = [{
      address = [{
        external_ipv4_address = [{
          address = yandex_vpc_address.morsh-addr-pub.external_ipv4_address[0].address
        }]
        external_ipv6_address = []
        internal_ipv4_address = []
      }]
      ports = [443]
    }]
    http = []
    stream = []
    tls = [{
      default_handler = [{
        http_handler = [{
          http_router_id = module.internet-alb-http-router-project.id
          http2_options = []
        }]
        certificate_ids = [yandex_cm_certificate.polar-net-ru.id]
        stream_handler = []
      }]
      sni_handler = []
      
    }]
  }]
}

module "internet-alb-backend-project" {

  source = "git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Backend-Group-Module?ref=tags/1.1.3"
  
  name = "internet-edge"
  description = "Internet edge to K8S ingress and servers"
}

module "internet-alb-target-group-project" {
  
  source = "git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Target-Group-Module?ref=tags/1.1.1"

   name = "internet-edge"
   description = "Internet edge to K8S ingress and servers"
   group = "internet-edge"

}

module "internet-alb-http-router-project" {
  
   source = "git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Http-Router-Module?ref=tags/1.1.0"

   name = "internet-edge"
   description = "Internet edge to K8S ingress and servers"
   group = "internet-edge"

}

module "internet-alb-virtual-host-project" {
  
   source = "git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Virtual-Host-Module?ref=tags/1.0.0"

   name = "internet-edge"

   http_router_id = module.internet-alb-http-router-project.id
}

####################################################
#           Network Load-Balancers                 #
#                                                  #
####################################################

#module "k8s-nlb-control-plane" {
  
 # source = "git::https://github.com/Morshimus/terraform-yandex-cloud-network-load-balancer-module?ref=tags/1.1.1"

  #type = "internal"

  #region_id = "ru-central1"

  #listener = [
  #  {
  #    name        = "k8s-listener"
  #    port        = "8443"
  #    target_port = "6443"
  #    protocol    = "tcp"
  #    internal_address_spec = [
  #      {
  #        subnet_id = yandex_vpc_subnet.morsh-subnet-a.id
  #      }
  #    ]
  #  }
  #]
  
  #attached_target_group = [
  #  {
  #    target_group_id = module.k8s-target-control-plane.id
  #    healthcheck = [
  #      {
  #        name = "k8s-server-http-check"
  #        tcp_options = [
  #          {
  #            port = 6443
  #          }
  #        ]
  #      }
  #    ]
  #  }
  #]

#  group   = var.group
#  prefix  = "k8s-nlb"
#  postfix = "001"
#}

#module "k8s-target-control-plane" {
#  source = "git::https://github.com/Morshimus/terraform-yandex-cloud-network-load-balancer-target-group-module?ref=tags/1.1.0"
#
#   target = [ 
#    for s in keys(var.k8s_node_cp.name):
#    merge({ "address" = module.k8s-node-control-plane[s].internal_ip_address_server[0] }, {"subnet_id" = yandex_vpc_subnet.morsh-subnet-a.id })
#
#  ]

#  group   = var.group
#  prefix  = "k8s-target"
#  postfix = "001"
#
#  depends_on = [
#    module.k8s-node-control-plane
#  ]
#}

####################################################
#             Certificate Managers                 #
#                                                  #
####################################################

resource "yandex_cm_certificate" "polar-net-ru" {
  name    = "polar-net-ru"
  domains = ["polar.net.ru", "*.polar.net.ru"]

  managed {
    challenge_type  = "DNS_CNAME"
    challenge_count = 1 
  }

  lifecycle {
    ignore_changes = [ 
      challenges,
      created_at,
      domains,
      folder_id,
      id,
      issued_at,
      issuer,
      labels,
      name,
      status,
      subject,
      type,
      updated_at

     ]
  }
}

####################################################
#              Security Groups                     #
#                                                  #
####################################################

####################################################
#             Compute Instances                    #
#                                                  #
####################################################
resource "yandex_compute_placement_group" "group_cp" {
  name   = "group-cp"
#  labels = local.labels

  lifecycle {
    ignore_changes = [
      name,
      labels
    ]
  }
} 
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

  placement_policy = [
    {
      placement_group_id = yandex_compute_placement_group.group_cp.id
    }
  ]

  network_interface = [
    {
      subnet_id      = yandex_vpc_subnet.morsh-subnet-a.id
      nat            = true
    }
  ]


  prefix      = each.value
  postfix     = each.key
  vm_vcpu_qty = 4
  vm_ram_qty  = 8
  cloud-init = local.cloud-init-k8s-node-deb
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
      subnet_id      = yandex_vpc_subnet.morsh-subnet-a.id
      nat            = true
    }
  ]


  prefix      = each.value
  postfix     = each.key
  vm_vcpu_qty = 4
  vm_ram_qty  = 8
  cloud-init = local.cloud-init-k8s-node-deb
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
      subnet_id      = yandex_vpc_subnet.morsh-subnet-a.id
      nat            = true
    }
  ]


  prefix      = each.value
  postfix     = each.key
  vm_vcpu_qty = 4
  vm_ram_qty  = 8
  cloud-init = local.cloud-init-ci-cd-monitor-deb
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

#resource "local_file" "k8s_group_vars_all" {
#  content  = local.k8s_group_vars_all_template
#  filename = "${path.module}/inventory/sf-cluster/group_vars/all/all.yml"
#}

#resource "local_file" "k8s_group_vars_cluster" {
#  content  = local.k8s_group_vars_cluster_template
#  filename = "${path.module}/inventory/sf-cluster/group_vars/k8s_cluster/k8s-cluster.yml"
#}


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
      GITHUB_USER = data.ansiblevault_path.github-user.value
    }
  } 
}
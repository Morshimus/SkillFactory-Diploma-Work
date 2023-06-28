####################################################
#             Compute Instances                    #
#                                                  #
####################################################
variable "k8s_node_cp" {
  type = object({
    name        = map(string),
    etcd_member = map(bool)
  })
  description = <<-EOT
    Number of control plane nodes in k8s cluster. 
    For name:
      Key - is postfix
      Value - is prefix
    For etcd_member:
      Key - is name
      Value - is type
    EOT
  default = {
    name = {
      "001" = "k8s-cp-polar-"
    },
    etcd_member = {
      "001" = true
    }
  }
}

variable "k8s_node_worker" {
  type = object({
    name        = map(string)
    etcd_member = map(bool)
  })
  description = <<-EOT
    Number of worker nodes in k8s cluster.
    For name:
      Key - is postfix
      Value - is prefix
    For etcd_member:
      Key - is name
      Value - is type
    EOT
  default = {
    name = {
      "002" = "k8s-worker-polar-"
    },
    etcd_member = {
      "002" = false
    }

  }
}

variable "k8s_outside_srv" {
  type = object({
    name       = map(string)
    ci-cd      = map(bool)
    monitoring = map(bool)
    bastion    = map(bool)
  })
  description = <<-EOT
    Number of external servers outside of k8s cluster.
    For name:
      Key - is postfix
      Value - is prefix
    For ci-cd:
      Key - is name
      Value - is type
    For monitoring:
      Key - is name
      Value - is type
    For bastion:
      Key - is name
      Value - is type     
    EOT
  default = {
    name = {
      "003" = "srv-ext-polar-"
    },
    ci-cd = {
      "003" = true
    },
    monitoring = {
      "003" = true
    },
    bastion = {}
  }
}


variable "os_disk_size" {
  type        = string
  default     = "50"
  description = "Size of required vm"

}

variable "useros" {
  type    = string
  default = "morsh-adm"
}


####################################################
#                    VPC                           #
#                                                  #
####################################################

variable "network_name_yandex" {
  type        = string
  description = "Created netowork in yandex.cloud name"
  default     = "morsh_vpc"
}
variable "subnet_a_name_yandex" {
  type        = string
  default     = "morsh-subnet-a"
  description = "Subnet for 1st instance"

}

variable "subnet_a_v4_cidr_blocks_yandex" {
  type        = list(string)
  default     = ["192.168.21.0/24"]
  description = "IPv4 network for 1st instance subnet"
}

variable "subnet_a_description_yandex" {
  type    = string
  default = "Subnet A for morshimus instances"
}


####################################################
#                    DNS                           #
#                                                  #
####################################################

variable "dns_name_pub" {
  type        = string
  default     = "polar-dns"
  description = "(Required) The DNS name this record set will apply to."
}

variable "dns_zone_pub" {
  type        = string
  default     = "polar.net.ru."
  description = "(Required) The DNS name of this zone, e.g. 'example.com.'. Must ends with dot."
}


####################################################
#                 Provider                         #
#                                                  #
####################################################

variable "service_account_key_yandex" {
  type        = string
  default     = "./key.json"
  description = "Local storing service key. Not in git tracking"
}

variable "zone_yandex_a" {
  type        = string
  default     = "ru-central1-a"
  description = "Zone of 1st instance in yandex cloud"
}

variable "cloud_id_yandex" {
  type        = string
  description = "Cloud id of yandex.cloud provider"
}


variable "folder_id_yandex" {
  type        = string
  description = "Folder id of yandex.cloud provider"
}
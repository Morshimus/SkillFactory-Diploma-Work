terraform {
  required_version = ">= 1.3.5"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.84.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    ansiblevault = {
          source  = "MeilleursAgents/ansiblevault"
          version = "= 2.2.0"
    }
  }
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    region   = "ru-central1"
    key      = "morsh-k8s-diploma.tfstate"


    skip_region_validation      = true
    skip_credentials_validation = true
  }
}





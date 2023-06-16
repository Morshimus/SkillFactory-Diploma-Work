provider "yandex" {
  zone                     = var.zone_yandex_a
  cloud_id                 = var.cloud_id_yandex
  folder_id                = var.folder_id_yandex
  service_account_key_file = var.service_account_key_yandex
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/inventory/sf-cluster/artifacts/admin.conf"
  }
}
provider "yandex" {
  zone                     = var.zone_yandex_a
  cloud_id                 = var.cloud_id_yandex
  folder_id                = var.folder_id_yandex
  service_account_key_file = var.service_account_key_yandex
}

provider "ansiblevault" {
  vault_path  = "${local.loc_path}.vault_pass_diploma"
  root_folder = local.loc_path
}
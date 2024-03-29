locals {

  loc_path = "${path.module}/"

  # cloud-init = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
  #   adm_pub_key = tls_private_key.key.public_key_openssh
  #   useros      = var.useros
  #   }
  # )
  cloud-init-k8s-node-deb = templatefile("${path.module}/templates/cloud-init-k8s-node-deb.yaml.tpl", {
    adm_pub_key = tls_private_key.key.public_key_openssh
    useros      = var.useros
    }
  )
  cloud-init-ci-cd-monitor-deb = templatefile("${path.module}/templates/cloud-init-ci-cd-monitor-deb.yaml.tpl", {
    adm_pub_key = tls_private_key.key.public_key_openssh
    useros      = var.useros
    }
  )

  raw_secrets_sf_web_app_template = templatefile("${path.module}/templates/raw_secrets_sf_web_app.yaml.tpl", {
    db_username = base64encode(data.ansiblevault_path.db_username.value)
    db_password = base64encode(data.ansiblevault_path.db_password.value)
    }
  )

  raw_secrets_infra_template = templatefile("${path.module}/templates/raw_secrets_infra.yaml.tpl", {
    db_password          = base64encode(data.ansiblevault_path.db_password.value)
    db_postgres_password = base64encode(data.ansiblevault_path.db_postgres_password.value)
    }
  )
  k8s_cluster_node_ip_priv = merge(
    { for i in keys(var.k8s_node_cp.name) : i => module.k8s-node-control-plane[i].internal_ip_address_server[0] },
    { for i in keys(var.k8s_node_worker.name) : i => module.k8s-node-worker[i].internal_ip_address_server[0] }
  )

  k8s_cluster_cp_name     = { for i in keys(var.k8s_node_cp.name) : i => module.k8s-node-control-plane[i].hostname_server }
  k8s_cluster_worker_name = { for i in keys(var.k8s_node_worker.name) : i => module.k8s-node-worker[i].hostname_server }

  k8s_cluster_cp_ip_pub  = length(keys(var.k8s_node_cp.name)) == 1 ? { for i in keys(var.k8s_node_cp.name) : "ip" => module.k8s-node-control-plane[i].external_ip_address_server[0] } : null
  k8s_cluster_cp_ip_priv = length(keys(var.k8s_node_cp.name)) == 1 ? { for i in keys(var.k8s_node_cp.name) : "ip" => module.k8s-node-control-plane[i].internal_ip_address_server[0] } : null

  provisioning_yaml_tpl_template = templatefile("${path.module}/templates/provisioning.yaml.tpl", {

    k8s_cluster_cp_name = local.k8s_cluster_cp_name
    k8s_cluster_node_name = merge(
      local.k8s_cluster_cp_name,
      local.k8s_cluster_worker_name
    )

    }
  )

  promtail_release_yaml_tpl = templatefile("${path.module}/templates/promtail_release.yaml.tpl", {

    external_servers_name  = { for i in keys(var.k8s_outside_srv.name) : i => module.k8s-outside-servers[i].hostname_server }
    monitoring_member_name = length(var.k8s_outside_srv.monitoring) > 0 ? { for i in keys(var.k8s_outside_srv.monitoring) : i => var.k8s_outside_srv.monitoring[i] } : null
    }
  )

  ansible_template = templatefile(
    "${path.module}/templates/ansible_inventory_template.tpl",
    {
      user                    = var.useros
      k8s_cluster_cp_name     = local.k8s_cluster_cp_name
      k8s_cluster_worker_name = local.k8s_cluster_worker_name
      k8s_cluster_node_name = merge(
        local.k8s_cluster_cp_name,
        local.k8s_cluster_worker_name
      )

      k8s_cluster_node_ip = merge(
        { for i in keys(var.k8s_node_cp.name) : i => module.k8s-node-control-plane[i].external_ip_address_server[0] },
        { for i in keys(var.k8s_node_worker.name) : i => module.k8s-node-worker[i].external_ip_address_server[0] }
      )
      etcd_member_name = merge(
        { for i in keys(var.k8s_node_cp.etcd_member) : i => var.k8s_node_cp.etcd_member[i] },
        { for i in keys(var.k8s_node_worker.etcd_member) : i => var.k8s_node_worker.etcd_member[i] }
      )


      external_servers_name = { for i in keys(var.k8s_outside_srv.name) : i => module.k8s-outside-servers[i].hostname_server }

      external_servers_ip = { for i in keys(var.k8s_outside_srv.name) : i => module.k8s-outside-servers[i].external_ip_address_server[0] }

      bastion_member_name = length(var.k8s_outside_srv.bastion) > 0 ? { for i in keys(var.k8s_outside_srv.bastion) : i => var.k8s_outside_srv.bastion[i] } : null

      monitoring_member_name = length(var.k8s_outside_srv.monitoring) > 0 ? { for i in keys(var.k8s_outside_srv.monitoring) : i => var.k8s_outside_srv.monitoring[i] } : null

      ci_cd_member_name = length(var.k8s_outside_srv.ci-cd) > 0 ? { for i in keys(var.k8s_outside_srv.ci-cd) : i => var.k8s_outside_srv.ci-cd[i] } : null
    }
  )
}
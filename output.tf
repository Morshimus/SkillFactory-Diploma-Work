output "k8s_cluster_nodes_ip_pub" {
  value = merge(
    { for i in keys(var.k8s_node_cp.name) : module.k8s-node-control-plane[i].hostname_server => module.k8s-node-control-plane[i].external_ip_address_server[0] },
    { for i in keys(var.k8s_node_worker.name) : module.k8s-node-worker[i].hostname_server => module.k8s-node-worker[i].external_ip_address_server[0] }
  )

}

output "k8s_cluster_nodes_ip_priv" {
  value = merge(
    { for i in keys(var.k8s_node_cp.name) : module.k8s-node-control-plane[i].hostname_server => module.k8s-node-control-plane[i].internal_ip_address_server[0] },
    { for i in keys(var.k8s_node_worker.name) : module.k8s-node-worker[i].hostname_server => module.k8s-node-worker[i].internal_ip_address_server[0] }
  )

}


output "external_servers_nodes_ip_pub" {
  value = { for i in keys(var.k8s_outside_srv.name) : module.k8s-outside-servers[i].hostname_server => module.k8s-outside-servers[i].external_ip_address_server[0] }

}

output "external_servers_nodes_ip_priv" {
  value = { for i in keys(var.k8s_outside_srv.name) : module.k8s-outside-servers[i].hostname_server => module.k8s-outside-servers[i].internal_ip_address_server[0] }

}
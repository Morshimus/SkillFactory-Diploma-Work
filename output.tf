output "k8s_cluster_node_ip" {
    value = merge(
        {for i in keys(var.k8s_node_cp.name) : "${i}" => module.k8s-node-control-plane["${i}"].external_ip_address_server[0] },
        {for i in keys(var.k8s_node_worker.name) : "${i}" => module.k8s-node-worker["${i}"].external_ip_address_server[0] }
      )
  
}

output "etcd_member" {
    value = merge(
        {for i in keys(var.k8s_node_cp.etcd_member) : "${i}" => var.k8s_node_cp.etcd_member["${i}"]  },
        {for i in keys(var.k8s_node_worker.etcd_member) : "${i}" => var.k8s_node_worker.etcd_member["${i}"] }
      )
  
}
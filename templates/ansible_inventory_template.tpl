[all]
%{ for index, node in k8s_cluster_node_name ~}
${node}  ansible_host=${lookup(k8s_cluster_node_ip, index, 0 )} ansible_user=${user} ansible_become=yes %{ if lookup(etcd_member_name,  index , false) != false }etcd_member_name=etcd${index}%{ else }%{ endif }
%{ endfor ~}

%{ if bastion_member_name != null}
[bastion]
%{ for index, server in external_servers_name.name ~}
%{ if lookup(bastion_member_name ,  index , false) != false }${server} ansible_host=${lookup(external_servers_ip, index, 0)} ansible_user=${user}
%{ else }
%{ endif }
%{ endfor ~}
%{ else }
%{ endif }

[kube-master]
%{ for index, node in k8s_cluster_cp_name ~}
${node}
%{ endfor ~}


[etcd]
%{ for index, node in k8s_cluster_node_name ~}
%{ if lookup(etcd_member_name,  index , false) != false }${node}
%{ else }
%{ endif }
%{ endfor ~}

[kube-node]
%{ for index, node in k8s_cluster_worker_name ~}
${node}
%{ endfor ~}


[calico-rr]

[k8s-cluster:children]
kube-master
kube-node
calico-rr

%{ if monitoring_member_name != null}
[monitoring]
%{ for index, server in external_servers_name ~}
%{ if lookup(monitoring_member_name ,  index , false) != false }${server} ansible_host=${lookup(external_servers_ip, index, 0)} ansible_user=${user} ansible_become=yes
%{ else }
%{ endif }
%{ endfor ~}
%{ else }
%{ endif }

%{ if ci_cd_member_name != null}
[Jenkins-CI]
%{ for index, server in external_servers_name ~}
%{ if lookup(ci_cd_member_name ,  index , false) != false }${server} ansible_host=${lookup(external_servers_ip, index, 0)} ansible_user=${user} ansible_become=yes
%{ else }
%{ endif }
%{ endfor ~}
[Jenkins-CI:vars]
Jenkins_Docker_root=/opt/morsh_ci
%{ else }
%{ endif }

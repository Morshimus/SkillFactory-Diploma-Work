[all]
%{ for index, node in k8s_cluster_node_name ~}
node ansible_host=${k8s_cluster_node_ip[index]} ansible_user=${user} %{ if etcd_member_name[node] != false }etcd_member_name=etcd[index]%{ else }%{ endif }
%{ endfor ~}

[kube_control_plane]
%{ for index, node in k8s_cluster_cp_name ~}
node
%{ endfor ~}


[etcd]
%{ for index, node in k8s_cluster_etcd_name ~}
node
%{ endfor ~}

[kube_node]
%{ for index, node in k8s_cluster_worker_name ~}
node
%{ endfor ~}


[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr


[monitoring]
%{ for index, server in monitor_servers_name ~}
server ansible_host=${monitor_servers_ip[index]} ansible_user=${user}
%{ endfor ~}

[Jenkins-CI]
%{ for index, server ci_servers_name ~}
server ansible_host=${ci_servers_ip[index]} ansible_user=${user}
%{ endfor ~}
[Jenkins-CI:vars]
Jenkins_Docker_root=/opt/morsh_ci

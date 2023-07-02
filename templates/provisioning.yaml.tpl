---
- hosts: Jenkins-CI
  gather_facts: yes
  become: yes   
  roles:
    - role: Jenkins
      
- hosts: monitoring
  gather_facts: yes
  become: yes
  roles:
     - role: Prometheus
       vars:
         node_exporter_targets:
          - nodeexporter:9100
%{ for index, node in k8s_cluster_node_name ~}
          - ${node}:30091
%{ endfor ~}
         cadvisor_exporter_targets:
          - cadvisor:8080
%{ for index, node in k8s_cluster_node_name ~}
          - ${node}:9080
%{ endfor ~}
         nginx_exporter_targets:
%{ for index, node in k8s_cluster_node_name ~}
          - ${node}:10254
%{ endfor ~}
         postgresql_exporter_targets:
%{ for index, node in k8s_cluster_cp_name ~}
          - ${node}:9187
%{ endfor ~}
         Prometheus_Docker_root: /opt/morsh_monit
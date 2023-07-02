# SkillFactory Diploma Work

* *Ссылки которые связаны с проектом.*

## [Skillfactory Diploma Work Web App](https://github.com/Morshimus/SkillFactory-Diploma-Work-Web-App) - Приложение написанное на framework Django, язык python3

## [Skillfactory Diploma Work CI Role](https://github.com/Morshimus/SkillFactory-Diploma-Work-CI-Role) - Роль Ansible для деплоя CI\CD Jenkins Pipelines

## [Skillfactory Diploma Work Prometheus Stack Role](https://github.com/Morshimus/SkillFactory-Diploma-Work-Loki-Prom-Grafana-Role) - Роль Ansible для деплоя кластера мониторинга Prometheus с Loki и Grafana

## [Skillfactory Diploma Work Helm Charts](https://github.com/Morshimus/SkillFactory-Diploma-Work-Helm-Charts) - Helm шаблон для приложения, плюс модифицированный шаблоны promtail и  postgresql. Работает как helm репозиторий

### Схема Virtual Privat Cloud Network

```mermaid
graph TD

subgraph VPC
    network["yandex_vpc_network<br/>(morsh-network)"]
    subnet["yandex_vpc_subnet<br/>(morsh-subnet-a)"]
    address["yandex_vpc_address<br/>(morsh-addr-pub)"]
end

network --> subnet
subnet --> address

```

### Схема DNS

```mermaid
graph TD

subgraph DNS
    dns_zone["yandex_dns_zone<br/>(dns_pub)"]
    dns_recordset_polar["yandex_dns_recordset<br/>(polar-net-ru)"]
    dns_recordset_k8s["yandex_dns_recordset<br/>(k8s)"]
    dns_recordset_jenkins["yandex_dns_recordset<br/>(jenkins)"]
    dns_recordset_grafana["yandex_dns_recordset<br/>(grafana)"]
    dns_recordset_skillfactory["yandex_dns_recordset<br/>(skillfactory)"]
end

dns_zone
dns_recordset_polar --> dns_zone
dns_recordset_k8s --> dns_zone
dns_recordset_jenkins --> dns_zone
dns_recordset_grafana --> dns_zone
dns_recordset_skillfactory --> dns_zone

```

### Схема Application Load Balancers

```mermaid

graph TD

subgraph ApplicationLoadBalancers
    http_router["module.internet-alb-http-router-project"]
    backend_jenkins["module.internet-alb-backend-jenkins-project"]
    backend_grafana["module.internet-alb-backend-grafana-project"]
    backend_skillfactory["module.internet-alb-backend-skillfactory-project"]
    target_group_jenkins["module.internet-alb-target-group-jenkins-project"]
    target_group_grafana["module.internet-alb-target-group-grafana-project"]
    target_group_skillfactory["module.internet-alb-target-group-skillfactory-project"]
    virtual_host_jenkins["module.internet-alb-virtual-host-jenkins-project"]
    virtual_host_grafana["module.internet-alb-virtual-host-grafana-project"]
    virtual_host_skillfactory["module.internet-alb-virtual-host-skillfactory-project"]
end
http_router --> backend_jenkins
http_router --> backend_grafana
http_router --> backend_skillfactory

backend_jenkins --> target_group_jenkins
backend_grafana --> target_group_grafana
backend_skillfactory --> target_group_skillfactory

target_group_jenkins --> virtual_host_jenkins
target_group_grafana --> virtual_host_grafana
target_group_skillfactory --> virtual_host_skillfactory

```

### Схема Certificate Manager

```mermaid
graph LR

subgraph CertificateManager
    CertificateManagerResource[Certificate Manager]
    
    ssl-certificate[SSL Certificate]
    certificate-authority[Certificate Authority]
    certificate-revocation-list[Certificate Revocation List]

    ssl-certificate -- Manages --> yandex_cm_certificate_polar_net_ru[Yandex CM Certificate]
    certificate-authority -- Manages --> yandex_cm_certificate_authority_polar_net_ru[Yandex CM Certificate Authority]
    certificate-revocation-list -- Manages --> yandex_cm_certificate_revocation_list_polar_net_ru[Yandex CM Certificate Revocation List]

end

yandex_cm_certificate_polar_net_ru -- Secures --> internet-alb-target-group-skillfactory-project
yandex_cm_certificate_polar_net_ru -- Secures --> internet-alb-virtual-host-jenkins-project
yandex_cm_certificate_polar_net_ru -- Secures --> internet-alb-virtual-host-grafana-project
yandex_cm_certificate_polar_net_ru -- Used by --> resource-yandex_dns_recordset_polar_net_ru

subgraph ApplicationLoadBalancers
    internet-alb-target-group-skillfactory-project -- Redirects traffic to --> k8s-node-control-plane
    internet-alb-virtual-host-jenkins-project -- Redirects traffic to --> k8s-outside-servers
    internet-alb-virtual-host-grafana-project -- Redirects traffic to --> k8s-outside-servers
end

yandex_cm_certificate_authority_polar_net_ru -- Signs --> yandex_cm_certificate_polar_net_ru
yandex_cm_certificate_revocation_list_polar_net_ru -- Revokes --> yandex_cm_certificate_polar_net_ru

yandex_cm_certificate_polar_net_ru --> yandex_cm_ca_cert_polar_net_ru[Let's Encrypt CA Cert]
yandex_cm_certificate_authority_polar_net_ru --> yandex_cm_ca_cert_polar_net_ru
yandex_cm_certificate_revocation_list_polar_net_ru --> yandex_cm_ca_cert_polar_net_ru

resource-yandex_dns_recordset_polar_net_ru --> yandex_cm_certificate_polar_net_ru

```

### Схема Compute Instances

```mermaid
graph LR

subgraph ComputeInstances
    ComputeInstancesResources[Compute Instances] -- Contains --> k8s-node-control-plane[k8s-node-control-plane]
    ComputeInstancesResources -- Contains --> k8s-node-worker[k8s-node-worker]
    ComputeInstancesResources -- Contains --> k8s-outside-servers[k8s-outside-servers]

    k8s-node-control-plane -- Connects to --> k8s-node-control-plane-instance[k8s-node-control-plane Instance]
    k8s-node-worker -- Connects to --> k8s-node-worker-instance[k8s-node-worker Instance]
    k8s-outside-servers -- Connects to --> k8s-outside-servers-instance[k8s-outside-servers Instance]

    k8s-node-control-plane-instance --> k8s-node-control-plane-vm[Virtual Machine]
    k8s-node-worker-instance --> k8s-node-worker-vm[Virtual Machine]
    k8s-outside-servers-instance --> k8s-outside-servers-vm[Virtual Machine]

    k8s-node-control-plane-vm --> os-disk-control-plane[OS Disk]
    k8s-node-worker-vm --> os-disk-worker[OS Disk]
    k8s-outside-servers-vm --> os-disk-outside-servers[OS Disk]

    os-disk-control-plane --> yandex_compute_disk_control_plane[Yandex Compute Disk]
    os-disk-worker --> yandex_compute_disk_worker[Yandex Compute Disk]
    os-disk-outside-servers --> yandex_compute_disk_outside_servers[Yandex Compute Disk]

    yandex_compute_disk_control_plane --> yandex_compute_instance_control_plane[Yandex Compute Instance]
    yandex_compute_disk_worker --> yandex_compute_instance_worker[Yandex Compute Instance]
    yandex_compute_disk_outside_servers --> yandex_compute_instance_outside_servers[Yandex Compute Instance]

    yandex_compute_instance_control_plane --> yandex_vpc_subnet_morsh_subnet_a[Yandex VPC Subnet]
    yandex_compute_instance_worker --> yandex_vpc_subnet_morsh_subnet_a
    yandex_compute_instance_outside_servers --> yandex_vpc_subnet_morsh_subnet_a
end

```

### Схема Local Files

```mermaid

graph TD

    subgraph Local Files
        local_file_ansible_template --> templatefile --> local_file_ansible_inventory_template
        local_file_cloud_init_yaml_tpl --> templatefile --> local_file_cloud_init_yaml_tpl
        local_file_cloud_init_k8s_node_deb_yaml_tpl --> templatefile --> local_file_cloud_init_k8s_node_deb_yaml_tpl
        local_file_cloud_init_ci_cd_monitor_deb_yaml_tpl --> templatefile --> local_file_cloud_init_ci_cd_monitor_deb_yaml_tpl
        local_file_raw_secrets_sf_web_app_template --> templatefile --> local_file_raw_secrets_sf_web_app
        local_file_raw_secrets_infra_template --> templatefile --> local_file_raw_secrets_infra
        local_file_provisioning_yaml_tpl_template --> templatefile --> local_file_provisioning_yaml
        local_file_promtail_release_yaml_tpl --> templatefile --> local_file_promtail_release_yaml
        tls_private_key_key --> local_file_private_key
    end

    subgraph Destination Files
        local_file_raw_secrets_infra --> destination_file_raw_secrets_infra.yaml
        local_file_raw_secrets_sf_web_app --> destination_file_raw_secrets_sf_web_app.yaml
        local_file_promtail_release_yaml --> destination_file_promtail_release.yaml
        local_file_provisioning_yaml --> destination_file_provisioning.yaml
        local_file_ansible_inventory_template --> destination_file_yandex_inventory.ini
        local_file_private_key --> destination_file_SSH_KEY_FINAL
    end



```

### Схема Templates

```mermaid

graph TD

    subgraph Compute Instances
        variable_k8s_node_cp --> compute_instance_k8s_node_cp
        variable_k8s_node_worker --> compute_instance_k8s_node_worker
        variable_k8s_outside_servers --> compute_instance_k8s_outside_servers
    end

    subgraph Templates
        template_cloud-init-k8s-node-deb --> cloud-init-k8s-node-deb.yaml.tpl
        template_cloud-init-k8s-node-deb --> cloud-init-k8s-node-deb.yaml.tpl
        template_cloud-init-ci-cd-monitor-deb --> cloud-init-k8s-node-deb.yaml.tpl
    end

    compute_instance_k8s_node_cp --> template_cloud-init-k8s-node-deb
    compute_instance_k8s_node_worker --> template_cloud-init-k8s-node-deb
    compute_instance_k8s_outside_servers --> template_cloud-init-ci-cd-monitor-deb
    template_cloud-init-k8s-node-deb --> cloud-init-k8s-node-deb.yaml.tpl
    template_cloud-init-k8s-node-deb --> cloud-init-k8s-node-deb.yaml.tpl
    template_cloud-init-ci-cd-monitor-deb --> cloud-init-k8s-node-deb.yaml.tpl
    template_cloud-init-k8s-node-deb --> compute_instance_k8s_node_cp
    template_cloud-init-k8s-node-deb --> compute_instance_k8s_node_cp
    template_cloud-init-ci-cd-monitor-deb --> compute_instance_k8s_outside_servers


```

## Знакомство с инфраструктурой.

> Для выполнения задания был выбран путь динамической шаблонизации почти всего. Инвентаризация, файлы конфигураций секретов kubeseal, ansible playbooks и т.д.
![image](https://ams03pap004files.storage.live.com/y4m1wRjWrPpO1lMf_UYt_sxbO3SOYAs4lnBSW97qaM2R9MRHUMJpNDk135TUUkXTzqCUVs_V3NBeIxdvB9KVv99Dc6P-l2DEdbcVYuxpQ-byRCG2Kmgve9Hm3zsssZXWca3Ham193GhI8HNwIxkOU8oWF0244XtOgrSKkNcpDjAjuawmCNp2ciyFamn1P-DVLSL?encodeFailures=1&width=1550&height=865)

```tpl
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

```

> Было решено купить временный домен для дипломного проекта, им стал дешевенький polar.net.ru 3его уровня, но нам хватит более чем. Была проведена делегация домена в Yandex Cloud.
![image](https://ams03pap004files.storage.live.com/y4mnraSxVJ-faeC5D3YpUs6bsb8BnR2_hVrh7xh2Y0D9gADZmR8Uz6Gz04LQvFkjQa6UWTZgwezOBtDgCh_Ax6_b8VjC69MZK9plBYSiSu0pm_nxZKtP8NtVfoimQy1fOSx77G4ZdoR9Y81jOeQjGW3K9aF7rR3YfBJ4OI-FZ_wAxc3pQpPdhQcNWiaXsYRQEWD?encodeFailures=1&width=934&height=318)

> Из схемы DNS видно что были созданы записи, k8s.polar.net.ru для связи с kube api, все остальные приложения - это ALB
![image](https://ams03pap004files.storage.live.com/y4mAbg3UC70XJpnbTW-C_NCReZ2xymTfDSdOF9sIGxO9NbZGWVWPAOPWzotOgVXTkqBrDfwpZvR4XkoL0NW0jBQ6o5az3B2vqhBzzGm7_UQijZl-wx7tMoCHFuDNgwo5E_HbSZ67hl4YpUI6wFHLnKOp5r0JV0GZP8ExXCpAFraOCpbCpeZGzWOq12pfBY7Fr11?encodeFailures=1&width=856&height=681)

> Создан ресурс CertificateManage c помощью которого автоматически обновляется challange cname в буличной DNS зоне polar.net.ru
![image](https://ams03pap004files.storage.live.com/y4m4nYK3DzjfSg1C6gc1DzOdMFe1xA0BhRnr2u6HZj9AaEV-8NkjID0jw9GBRbJWtgm6I5wWxqaVyw8xP33Sc7F0MMrjtQf_4kzcNmuF8fSU8jgp8AFSqID92fPN8Gk_jQTHrZYTEncbeMsIYvRKtMmWB0TCGi8-11r55sIW1bQAYyExJMePgX9O0zQDGsmlF_s?encodeFailures=1&width=1072&height=679)

*Особеноостью в yandex является то, что terraform пытается пересоздать СM после каждого timstamp измениния. Принуждаем его расслабиться  и игнорировать изменения. Также, ставим таймаут при изменении\создании записи challange - должна пройти валидация, прежде чем сертифика будет выпущен\перевыпущен*

```hcl
resource "yandex_dns_recordset" "polar-net-ru" {
  count   = yandex_cm_certificate.polar-net-ru.managed[0].challenge_count
  zone_id = yandex_dns_zone.dns_pub.id
  name    = yandex_cm_certificate.polar-net-ru.challenges[count.index].dns_name
  type    = yandex_cm_certificate.polar-net-ru.challenges[count.index].dns_type
  data    = [yandex_cm_certificate.polar-net-ru.challenges[count.index].dns_value]
  ttl     = 60

  provisioner "local-exec" {
    command     = "Wait-Event -Timeout 600"
    interpreter = ["powershell.exe", "-NoProfile", "-c"]
  }

}

resource "yandex_cm_certificate" "polar-net-ru" {
  name    = "polar-net-ru"
  domains = ["polar.net.ru", "*.polar.net.ru"]

  managed {
    challenge_type  = "DNS_CNAME"
    challenge_count = 1
  }

  lifecycle {
    ignore_changes = [
      challenges,
      created_at,
      domains,
      folder_id,
      id,
      issued_at,
      issuer,
      labels,
      name,
      status,
      subject,
      type,
      updated_at

    ]
  }
}
```


> В целях безопасности, была применена Security Group к машинам за натом - разрешен только адрес запускающего apply data.http.myip , на ALB не распространяется. В идеале - все делаем через bastion, прописываем туннели для kube api - оставляем адрес только для ALB.
![image](https://ams03pap004files.storage.live.com/y4mo9-9adVBZ4o3k7q2qlpVl4AyWk0S_hTh0ZUUUbDi8DNGZMX4AaZpTXuHuMzuV5myk-u0SmVIGHcR3XckVmt1GBTNdBmKiqYhhsnSeqUSStxjhFCppdzffZAnfOBikQBM5NnzIr9b1u0Mc6zNijViVMQyKxaPGz3vNdlaFNvDfeyLEwP2aSc6wv_HDURxGK8a?encodeFailures=1&width=1756&height=802)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.5 |
| <a name="requirement_ansiblevault"></a> [ansiblevault](#requirement\_ansiblevault) | = 2.2.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.4.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | ~> 0.84.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ansiblevault"></a> [ansiblevault](#provider\_ansiblevault) | 2.2.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.84.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_internet-alb-backend-grafana-project"></a> [internet-alb-backend-grafana-project](#module\_internet-alb-backend-grafana-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Backend-Group-Module | tags/1.1.3 |
| <a name="module_internet-alb-backend-jenkins-project"></a> [internet-alb-backend-jenkins-project](#module\_internet-alb-backend-jenkins-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Backend-Group-Module | tags/1.1.3 |
| <a name="module_internet-alb-backend-skillfactory-project"></a> [internet-alb-backend-skillfactory-project](#module\_internet-alb-backend-skillfactory-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Backend-Group-Module | tags/1.1.3 |
| <a name="module_internet-alb-http-router-project"></a> [internet-alb-http-router-project](#module\_internet-alb-http-router-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Http-Router-Module | tags/1.1.0 |
| <a name="module_internet-alb-project"></a> [internet-alb-project](#module\_internet-alb-project) | git::https://github.com/Morshimus/terraform-yandex-cloud-application-load-balancer-module | tags/1.1.1 |
| <a name="module_internet-alb-target-group-grafana-project"></a> [internet-alb-target-group-grafana-project](#module\_internet-alb-target-group-grafana-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Target-Group-Module | tags/1.1.1 |
| <a name="module_internet-alb-target-group-jenkins-project"></a> [internet-alb-target-group-jenkins-project](#module\_internet-alb-target-group-jenkins-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Target-Group-Module | tags/1.1.1 |
| <a name="module_internet-alb-target-group-skillfactory-project"></a> [internet-alb-target-group-skillfactory-project](#module\_internet-alb-target-group-skillfactory-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Target-Group-Module | tags/1.1.1 |
| <a name="module_internet-alb-virtual-host-grafana-project"></a> [internet-alb-virtual-host-grafana-project](#module\_internet-alb-virtual-host-grafana-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Virtual-Host-Module | tags/1.0.0 |
| <a name="module_internet-alb-virtual-host-jenkins-project"></a> [internet-alb-virtual-host-jenkins-project](#module\_internet-alb-virtual-host-jenkins-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Virtual-Host-Module | tags/1.0.0 |
| <a name="module_internet-alb-virtual-host-skillfactory-project"></a> [internet-alb-virtual-host-skillfactory-project](#module\_internet-alb-virtual-host-skillfactory-project) | git::https://github.com/Morshimus/Terraform-Yandex-Cloud-Application-Load-Balancer-Virtual-Host-Module | tags/1.0.0 |
| <a name="module_k8s-node-control-plane"></a> [k8s-node-control-plane](#module\_k8s-node-control-plane) | git::https://github.com/Morshimus/yandex-cloud-instance-module | tags/1.1.2 |
| <a name="module_k8s-node-worker"></a> [k8s-node-worker](#module\_k8s-node-worker) | git::https://github.com/Morshimus/yandex-cloud-instance-module | tags/1.1.2 |
| <a name="module_k8s-outside-servers"></a> [k8s-outside-servers](#module\_k8s-outside-servers) | git::https://github.com/Morshimus/yandex-cloud-instance-module | tags/1.1.2 |

## Resources

| Name | Type |
|------|------|
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.promtail_release_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.provisioning_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.raw_secrets_infra](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.raw_secrets_sf_web_app](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.yandex_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [yandex_cm_certificate.polar-net-ru](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/cm_certificate) | resource |
| [yandex_compute_placement_group.group_cp](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_placement_group) | resource |
| [yandex_dns_recordset.grafana](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/dns_recordset) | resource |
| [yandex_dns_recordset.jenkins](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/dns_recordset) | resource |
| [yandex_dns_recordset.k8s](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/dns_recordset) | resource |
| [yandex_dns_recordset.polar-net-ru](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/dns_recordset) | resource |
| [yandex_dns_recordset.skillfactory](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/dns_recordset) | resource |
| [yandex_dns_zone.dns_pub](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/dns_zone) | resource |
| [yandex_vpc_address.morsh-addr-pub](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_address) | resource |
| [yandex_vpc_network.morsh-network](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_security_group.allow_myip](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_security_group) | resource |
| [yandex_vpc_subnet.morsh-subnet-a](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |
| [ansiblevault_path.db_password](https://registry.terraform.io/providers/MeilleursAgents/ansiblevault/2.2.0/docs/data-sources/path) | data source |
| [ansiblevault_path.db_postgres_password](https://registry.terraform.io/providers/MeilleursAgents/ansiblevault/2.2.0/docs/data-sources/path) | data source |
| [ansiblevault_path.db_username](https://registry.terraform.io/providers/MeilleursAgents/ansiblevault/2.2.0/docs/data-sources/path) | data source |
| [ansiblevault_path.github-token](https://registry.terraform.io/providers/MeilleursAgents/ansiblevault/2.2.0/docs/data-sources/path) | data source |
| [ansiblevault_path.github-user](https://registry.terraform.io/providers/MeilleursAgents/ansiblevault/2.2.0/docs/data-sources/path) | data source |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_id_yandex"></a> [cloud\_id\_yandex](#input\_cloud\_id\_yandex) | Cloud id of yandex.cloud provider | `string` | n/a | yes |
| <a name="input_dns_name_pub"></a> [dns\_name\_pub](#input\_dns\_name\_pub) | (Required) The DNS name this record set will apply to. | `string` | `"polar-dns"` | no |
| <a name="input_dns_zone_pub"></a> [dns\_zone\_pub](#input\_dns\_zone\_pub) | (Required) The DNS name of this zone, e.g. 'example.com.'. Must ends with dot. | `string` | `"polar.net.ru."` | no |
| <a name="input_folder_id_yandex"></a> [folder\_id\_yandex](#input\_folder\_id\_yandex) | Folder id of yandex.cloud provider | `string` | n/a | yes |
| <a name="input_k8s_node_cp"></a> [k8s\_node\_cp](#input\_k8s\_node\_cp) | Number of control plane nodes in k8s cluster. <br>For name:<br>  Key - is postfix<br>  Value - is prefix<br>For etcd\_member:<br>  Key - is postfix<br>  Value - is bool | <pre>object({<br>    name        = map(string),<br>    etcd_member = map(bool)<br>  })</pre> | <pre>{<br>  "etcd_member": {<br>    "001": true<br>  },<br>  "name": {<br>    "001": "k8s-cp-polar-"<br>  }<br>}</pre> | no |
| <a name="input_k8s_node_worker"></a> [k8s\_node\_worker](#input\_k8s\_node\_worker) | Number of worker nodes in k8s cluster.<br>For name:<br>  Key - is postfix<br>  Value - is prefix<br>For etcd\_member:<br>  Key - is postfix<br>  Value - is bool | <pre>object({<br>    name        = map(string)<br>    etcd_member = map(bool)<br>  })</pre> | <pre>{<br>  "etcd_member": {<br>    "002": false<br>  },<br>  "name": {<br>    "002": "k8s-worker-polar-"<br>  }<br>}</pre> | no |
| <a name="input_k8s_outside_srv"></a> [k8s\_outside\_srv](#input\_k8s\_outside\_srv) | Number of external servers outside of k8s cluster.<br>For name:<br>  Key - is postfix<br>  Value - is prefix<br>For ci-cd:<br>  Key - is postfix<br>  Value - is bool<br>For monitoring:<br>  Key - is postfix<br>  Value - is bool<br>For bastion:<br>  Key - is postfix<br>  Value - is bool | <pre>object({<br>    name       = map(string)<br>    ci-cd      = map(bool)<br>    monitoring = map(bool)<br>    bastion    = map(bool)<br>  })</pre> | <pre>{<br>  "bastion": {},<br>  "ci-cd": {<br>    "003": true<br>  },<br>  "monitoring": {<br>    "003": true<br>  },<br>  "name": {<br>    "003": "srv-ext-polar-"<br>  }<br>}</pre> | no |
| <a name="input_network_name_yandex"></a> [network\_name\_yandex](#input\_network\_name\_yandex) | Created netowork in yandex.cloud name | `string` | `"morsh_vpc"` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Size of required vm | `string` | `"50"` | no |
| <a name="input_service_account_key_yandex"></a> [service\_account\_key\_yandex](#input\_service\_account\_key\_yandex) | Local storing service key. Not in git tracking | `string` | `"./key.json"` | no |
| <a name="input_subnet_a_description_yandex"></a> [subnet\_a\_description\_yandex](#input\_subnet\_a\_description\_yandex) | n/a | `string` | `"Subnet A for morshimus instances"` | no |
| <a name="input_subnet_a_name_yandex"></a> [subnet\_a\_name\_yandex](#input\_subnet\_a\_name\_yandex) | Subnet for 1st instance | `string` | `"morsh-subnet-a"` | no |
| <a name="input_subnet_a_v4_cidr_blocks_yandex"></a> [subnet\_a\_v4\_cidr\_blocks\_yandex](#input\_subnet\_a\_v4\_cidr\_blocks\_yandex) | IPv4 network for 1st instance subnet | `list(string)` | <pre>[<br>  "192.168.21.0/24"<br>]</pre> | no |
| <a name="input_useros"></a> [useros](#input\_useros) | n/a | `string` | `"morsh-adm"` | no |
| <a name="input_zone_yandex_a"></a> [zone\_yandex\_a](#input\_zone\_yandex\_a) | Zone of 1st instance in yandex cloud | `string` | `"ru-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_servers_nodes_ip_priv"></a> [external\_servers\_nodes\_ip\_priv](#output\_external\_servers\_nodes\_ip\_priv) | n/a |
| <a name="output_external_servers_nodes_ip_pub"></a> [external\_servers\_nodes\_ip\_pub](#output\_external\_servers\_nodes\_ip\_pub) | n/a |
| <a name="output_k8s_cluster_nodes_ip_priv"></a> [k8s\_cluster\_nodes\_ip\_priv](#output\_k8s\_cluster\_nodes\_ip\_priv) | n/a |
| <a name="output_k8s_cluster_nodes_ip_pub"></a> [k8s\_cluster\_nodes\_ip\_pub](#output\_k8s\_cluster\_nodes\_ip\_pub) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

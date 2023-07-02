apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: promtail
  namespace: promtail
spec:
  releaseName: promtail
  chart:
    spec:
      chart: promtail
      sourceRef:
        kind: HelmRepository
        name: promtail
        namespace: promtail
  interval: 1m
  install:
    remediation:
      retries: 3
%{ if monitoring_member_name != null}
  values:
    config:
       clients:
%{ for index, server in external_servers_name ~}
%{ if lookup(monitoring_member_name ,  index , false) != false }         
            - ${server} 
%{ else }
%{ endif }
%{ endfor ~}

%{ else }
%{ endif }
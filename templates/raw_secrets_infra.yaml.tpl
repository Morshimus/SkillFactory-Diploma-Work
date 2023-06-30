apiVersion: v1
kind: Secret
metadata:
  labels:
    app.kubernetes.io/instance: postgresql
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: postgresql
    helm.sh/chart: postgresql-12.5.9
    helm.toolkit.fluxcd.io/name: postgresql
    helm.toolkit.fluxcd.io/namespace: postgresql
  name: postgresql
  namespace: postgresql
type: Opaque
data:
  password: ${db_password}
  postgres-password: ${db_postgres_password}
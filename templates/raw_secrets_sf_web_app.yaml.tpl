apiVersion: v1
kind: Secret
metadata:
  labels:
    app.kubernetes.io/managed-by: Helm
    helm.toolkit.fluxcd.io/name: sf-web-app
    helm.toolkit.fluxcd.io/namespace: sf-web-app
  name: sf-web-app-auth
  namespace: sf-web-app
type: Opaque
data:
  db-password: ${db_password}
  db-username: ${db_username}
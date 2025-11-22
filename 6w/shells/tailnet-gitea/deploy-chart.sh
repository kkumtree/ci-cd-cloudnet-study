#!/bin/bash
kubectl config use-context kind-mgmt
kubectl create ns gitea

# confirm cert and key is available in the path
kubectl -n gitea create secret tls gitea-selfsigned-tls \
  --cert=openssl-x509-output/kkumtree-ms-7a34.panda-ule.ts.net.crt \
  --key=openssl-x509-output/kkumtree-ms-7a34.panda-ule.ts.net.key

cat <<EOF > gitea-values-tailnet-prefix.yaml
global:
  namespace: "gitea"

gitea:
  config:
    APP_NAME: "Hello Gitea, kkumtree!"
    server:
      PROTOCOL: http
      DOMAIN: kkumtree-ms-7a34.panda-ule.ts.net
      CERT_FILE: /certs/tls.crt
      KEY_FILE: /certs/tls.key

postgresql-ha:
  enabled: false
postgresql:
  enabled: true

valkey-cluster:
  enabled: false
valkey:
  enabled: true

service:
  http:
    type: ClusterIP
    port: 443
    targetPort: 3000

ingress:
  enabled: true
  # className: nginx  # DEPRECATED
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
  hosts:
    - host: kkumtree-ms-7a34.panda-ule.ts.net
      paths: 
        - path: /
          pathType: Prefix
  tls:
    - secretName: gitea-selfsigned-tls
      hosts:
        - kkumtree-ms-7a34.panda-ule.ts.net

extraVolumes:
- name: gitea-tls
  secret:
    secretName: gitea-selfsigned-tls
extraVolumeMounts:
- name: gitea-tls
  readOnly: true
  mountPath: /certs

tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"

nodeSelector:
  node-role.kubernetes.io/control-plane: ""
EOF

# https://gitea.com/gitea/helm-gitea#installing  
helm repo add gitea-charts https://dl.gitea.com/charts/  
helm repo update  
helm install gitea gitea-charts/gitea --version 12.4.0 -f gitea-values-tailnet-prefix.yaml --namespace gitea  

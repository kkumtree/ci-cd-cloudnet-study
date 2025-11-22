#!/bin/bash
kubectl config use-context kind-mgmt
kubectl create ns gitea

# confirm cert and key is available in the path
kubectl -n gitea create secret tls gitea-selfsigned-tls \
  --cert=openssl-x509-output/kkumtree-ms-7a34.panda-ule.ts.net.crt \
  --key=openssl-x509-output/kkumtree-ms-7a34.panda-ule.ts.net.key


cat <<EOF > gitea-values-tailnet-prefix.yaml
global:
  domain: kkumtree-ms-7a34.panda-ule.ts.net

gitea:
  config:
    server:
      DOMAIN: kkumtree-ms-7a34.panda-ule.ts.net
      PROTOCOL: https
      ROOT_URL: https://kkumtree-ms-7a34.panda-ule.ts.net/_gitea/

ingress:
  enabled: true
  ingressClassName: nginx
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
  hosts:
    - host: kkumtree-ms-7a34.panda-ule.ts.net
      paths:
        - path: /_gitea
          pathType: Prefix
  tls:
    - secretName: gitea-selfsigned-tls
      hosts:
        - kkumtree-ms-7a34.panda-ule.ts.net

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

#!/bin/bash
kubectl config use-context kind-mgmt
kubectl create ns argocd

# confirm cert and key is available in the path
kubectl -n argocd create secret tls argocd-server-tls \
  --cert=openssl-x509-output/kkumtree-ms-7a34.panda-ule.ts.net.crt \
  --key=openssl-x509-output/kkumtree-ms-7a34.panda-ule.ts.net.key

# https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml

cat <<EOF > argocd-values-tailnet.yaml
global:
  domain: kkumtree-ms-7a34.panda-ule.ts.net

# # TLS certificate configuration via cert-manager
# # cert-manager가 있을 때, 활용.  
# certificate: 
#   enabled: true

server:
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    tls: true
EOF

# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#installing-the-chart
helm repo add argo https://argoproj.github.io/argo-helm
# https://github.com/argoproj/argo-helm/releases
helm install argocd argo/argo-cd --version 9.0.5 -f argocd-values-tailnet.yaml --namespace argocd

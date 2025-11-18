#!/bin/bash
kubectl config use-context kind-mgmt
kubectl create ns argocd

# confirm cert and key is available in the path
kubectl -n argocd create secret tls argocd-server-tls \
  --cert=openssl-x509-output/argocd.example.com.crt \
  --key=openssl-x509-output/argocd.example.com.key

# https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml

cat <<EOF > argocd-values.yaml
global:
  domain: argocd.example.com

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
    tls: true
EOF

# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#installing-the-chart
helm repo add argo https://argoproj.github.io/argo-helm
# https://github.com/argoproj/argo-helm/releases
helm install argocd argo/argo-cd --version 9.0.5 -f argocd-values.yaml --namespace argocd

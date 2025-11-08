#!/bin/bash
kubectl create ns argocd

# https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml

cat <<EOF > argocd-values.yaml
server:
  service:
    type: NodePort
    nodePortHttps: 30002
  extraArgs:
    - --insecure  # HTTPS 대신 HTTP 사용
EOF

# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#installing-the-chart
helm repo add argo https://argoproj.github.io/argo-helm
# https://github.com/argoproj/argo-helm/releases
helm install argocd argo/argo-cd --version 9.0.5 -f argocd-values.yaml --namespace argocd

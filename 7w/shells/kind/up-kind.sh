#!/bin/bash
sudo tailscale serve --tcp=443 off 2>/dev/null

kind version
kind create cluster --name vault --image kindest/node:v1.32.8 --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  labels:
    ingress-ready: true
  extraPortMappings:
  - containerPort: 80
    hostPort: 30080
EOF


echo "[Provisoning..] ingress-nginx in vault cluster"

kubectl config use-context kind-vault

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s


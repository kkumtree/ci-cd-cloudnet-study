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

# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

helm upgrade --install ingress-nginx ingress-nginx \
	--repo https://kubernetes.github.io/ingress-nginx \
	--namespace ingress-nginx --create-namespace \
	--set controller.hostPort.enabled=true \
	--set controller.service.type=NodePort

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

sudo tailscale serve -bg localhost:30080

kubectl apply -f whoami.yaml 

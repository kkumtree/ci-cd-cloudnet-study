#!/bin/bash
sudo tailscale serve --tcp=443 off 2>/dev/null

kind version
kind create cluster --name mgmt --image kindest/node:v1.32.8 --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# networking:
#   apiServerAddress: "0.0.0.0"
nodes:
- role: control-plane
  labels:
    ingress-ready: true
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
EOF

echo "[Provisoning..] ingress-nginx in mgmt cluster"

kubectl config use-context kind-mgmt

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl get deployment ingress-nginx-controller -n ingress-nginx -o yaml \
| sed '/- --publish-status-address=localhost/a\
        - --enable-ssl-passthrough' | kubectl apply -f -


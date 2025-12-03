#!/bin/bash
sudo tailscale serve off 2>/dev/null

kind version
kind create cluster --name vault --image kindest/node:v1.32.8 --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
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
  - containerPort: 30001
    hostPort: 30001
- role: worker
- role: worker
- role: worker
EOF

echo "[Provisoning..] ingress-nginx in vault cluster"

kubectl config use-context kind-vault

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=60s

kubectl patch deployment ingress-nginx-controller -n ingress-nginx \
  --type='merge' \
  -p='{
    "spec": {
      "template": {
        "spec": {
          "nodeSelector": {
            "ingress-ready": "true"
          }
        }
      }
    }
  }'

kubectl get deployment ingress-nginx-controller -n ingress-nginx -o yaml \
| sed '/- --publish-status-address=localhost/a\
        - --enable-ssl-passthrough' | kubectl apply -f -

sudo tailscale serve -bg localhost:80

kubectl apply -f whoami.yaml 

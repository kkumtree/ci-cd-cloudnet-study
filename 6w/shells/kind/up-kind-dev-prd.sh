#!/bin/bash
kind version
kind create cluster --name dev --image kindest/node:v1.32.8 --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# networking:
#   apiServerAddress: "0.0.0.0"
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 31000
    hostPort: 31000
EOF

kind create cluster --name prd --image kindest/node:v1.32.8 --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# networking:
#   apiServerAddress: "0.0.0.0"
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 32000
    hostPort: 32000
EOF

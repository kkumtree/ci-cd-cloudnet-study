#!/bin/bash

helm repo add hashicorp https://helm.releases.hashicorp.com

cat <<EOF > vault-ha.yaml
server:
  replicas: 3

  # Vault HA mode
  ha:
    enabled: true
    replicas: 3
    raft:
      enabled: true
    config: |
      ui = true
      listener "tcp" {
        tls_disable = 1                           
        address = "[::]:8200"                     
        cluster_address = "[::]:8201"           
      }

      service_registration "kubernetes" {}        

  readinessProbe:
    enabled: true

  # PVC for Raft storage
  dataStorage:
    enabled: true
    size: 10Gi

  service:
    enabled: true
    type: ClusterIP
    port: 8200
    targetPort: 8200

ui:
  enabled: true
  serviceType: "NodePort"
  externalPort: 8200
  serviceNodePort: 30000

injector:
  enabled: false
EOF

helm apply vault hashicorp/vault -n vault \
	-f vault-ha-ot.yaml \
	--version 0.31.0 \



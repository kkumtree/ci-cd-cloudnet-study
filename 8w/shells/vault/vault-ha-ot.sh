#!/bin/bash

helm repo add hashicorp https://helm.releases.hashicorp.com

cat <<EOF > vault-ha-ot.yaml
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
          # Enable unauthenticated metrics access (necessary for Prometheus Operator)
          telemetry {
            unauthenticated_metrics_access = "true"
          }
        }

        storage "raft" {
          path = "/vault/data"
        }

        service_registration "kubernetes" {}

        telemetry {
          prometheus_retention_time = "30s"
          disable_hostname = true
        }

    config: |
      ui = true
      listener "tcp" {
        tls_disable = 1                           
        address = "[::]:8200"                     
        cluster_address = "[::]:8201"
        telemetry {
          unauthenticated_metrics_access = "true"
        }
      }

      service_registration "kubernetes" {}     

      telemetry {
        prometheus_retention_time = "30s"
        disable_hostname = true
      }    

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

#serverTelemetry:
#  serviceMonitor:
#    enabled: true

ui:
  enabled: true
  serviceType: "NodePort"
  externalPort: 8200
  serviceNodePort: 30000

injector:
  enabled: false
EOF

helm upgrade vault hashicorp/vault -n vault \
	-f vault-ha-ot.yaml \
	--version 0.31.0 \
	--install --create-namespace



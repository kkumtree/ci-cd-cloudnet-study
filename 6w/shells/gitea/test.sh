#!/bin/bash

helm repo add gitea-charts https://dl.gitea.com/charts/
helm repo update
helm install gitea gitea-charts/gitea \
  --namespace gitea \
  --create-namespace \
  --set tolerations[0].key="node-role.kubernetes.io/control-plane" \
  --set tolerations[0].operator="Exists" \
  --set tolerations[0].effect="NoSchedule" \
  --set nodeSelector."node-role\.kubernetes\.io/control-plane"=""

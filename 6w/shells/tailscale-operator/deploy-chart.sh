#!/bin/bash

# 1. 환경 변수 설정 (쉘 파일 외부에서 실행)
# TAIL_OAUTH_CLIENT_ID="<YOUR_OAUTH_CLIENT_ID>"
# TAIL_OAUTH_CLIENT_SECRET="<YOUR_OAUTH_CLIENT_SECRET>"

# 2. 반복 작업을 수행할 클러스터 컨텍스트 목록 정의
#    현재 스크립트에 포함된 클러스터 컨텍스트 이름들을 나열합니다.
CONTEXTS=(
    "kind-mgmt"
    "kind-dev"
    "kind-prd"
)

# 3. Helm 레포지토리 설정 (반복할 필요 없이 한 번만 실행)
echo "--- Helm Repository 설정 ---"
helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm repo update

# 4. 클러스터 목록을 순회하며 작업 수행
for CONTEXT in "${CONTEXTS[@]}"; do

    echo "=================================================="
    echo "➡️ 클러스터 컨텍스트 변경: ${CONTEXT}"

    # a. 클러스터 컨텍스트 변경
    kubectl config use-context "${CONTEXT}"

    # b. Tailscale Operator 배포 (kind-mgmt에만 설정이 다를 경우 조건문 사용)
    #    현재 예시에서는 모든 클러스터에 동일한 operator 설정을 사용한다고 가정합니다.

    # 호스트 이름을 클러스터 이름에 따라 동적으로 설정
    OPERATOR_HOSTNAME="${CONTEXT}-k8s"

    echo "➡️ Tailscale Operator 배포 시작 (Hostname: ${OPERATOR_HOSTNAME})"

    helm upgrade --install tailscale-operator tailscale/tailscale-operator \
        --namespace=tailscale \
        --create-namespace \
				--version 1.90.8 \
        --set-string oauth.clientId="${TAIL_OAUTH_CLIENT_ID}" \
        --set-string oauth.clientSecret="${TAIL_OAUTH_CLIENT_SECRET}" \
        --set operatorConfig.hostname="${OPERATOR_HOSTNAME}" \
        --set-string apiServerProxyConfig.mode=true \
        --set tolerations[0].key="node-role.kubernetes.io/control-plane" \
        --set tolerations[0].operator="Exists" \
        --set tolerations[0].effect="NoSchedule" \
        --set nodeSelector."node-role\.kubernetes\.io/control-plane"="" \
        --wait

    echo "✅ ${CONTEXT} 클러스터 작업 완료."
done

echo "=================================================="
echo "모든 클러스터에 Tailscale Operator 배포 완료."

#!/bin/bash

kubectl config use-context kind-mgmt

cat <<EOF | kubectl apply -f - --wait
apiVersion: tailscale.com/v1alpha1
kind: DNSConfig
metadata:
  name: ts-dns
spec:
  nameserver:
    image:
      repo: tailscale/k8s-nameserver
      tag: unstable
EOF

kubectl get dnsconfig ts-dns -o jsonpath='{.status.conditions[*].status}'
echo ""
kubectl get dnsconfig ts-dns -o jsonpath='{.status.conditions[*].type}'
echo ""

TS_IP=$(kubectl get dnsconfig ts-dns -o jsonpath='{.status.nameserver.ip}')

if [ -z "$TS_IP" ]; then
  echo "Error: Tailscale Nameserver IP를 찾을 수 없습니다. ts-dns 상태를 확인하세요."
  exit 1
fi

echo "Found Tailscale Nameserver IP: $TS_IP"

# 2. 현재 CoreDNS의 Corefile을 임시 파일로 추출
kubectl get configmap coredns -n kube-system -o jsonpath='{.data.Corefile}' > Corefile.temp

# 3. 중복 설정 방지 (이미 설정되어 있는지 확인)
if grep -q "ts.net:53" Corefile.temp; then
  echo "Configuration already exists in Corefile. Skipping update."
  rm Corefile.temp
  exit 0
fi

# 4. Corefile 내용 끝에 Tailscale 설정 추가
# 주의: CoreDNS 설정 문법에 맞게 줄바꿈과 블록을 추가합니다.
cat <<EOF >> Corefile.temp

ts.net:53 {
    errors
    cache 30
    forward . $TS_IP
}
EOF

# 5. 수정된 내용을 바탕으로 ConfigMap 업데이트 (Dry Run 후 Apply)
# --from-file을 사용하면 줄바꿈 등을 안전하게 처리할 수 있습니다.
kubectl create configmap coredns -n kube-system --from-file=Corefile=Corefile.temp --dry-run=client -o yaml | kubectl apply -f -

# 6. CoreDNS 재시작 (설정 반영을 위해 필수)
kubectl rollout restart deployment coredns -n kube-system

# 7. 임시 파일 삭제
rm Corefile.temp

echo "CoreDNS updated and restarted successfully!"

kubectl get configmap coredns -n kube-system -o jsonpath='{.data.Corefile}' |\
tail -n 5

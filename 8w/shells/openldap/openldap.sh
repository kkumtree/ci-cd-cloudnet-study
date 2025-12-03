#!/bin/bash

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: openldap
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openldap
  namespace: openldap
spec:
  replicas: 1
  selector:
    matchLabels:
      app: openldap
  template:
    metadata:
      labels:
        app: openldap
    spec:
      containers:
        - name: openldap
          image: osixia/openldap:1.5.0
          ports:
            - containerPort: 389
              name: ldap
            - containerPort: 636
              name: ldaps
          env:
            - name: LDAP_ORGANISATION    # 기관명, LDAP 기본 정보 생성 시 사용
              value: "Example Org"
            - name: LDAP_DOMAIN          # LDAP 기본 Base DN 을 자동 생성
              value: "example.org"
            - name: LDAP_ADMIN_PASSWORD  # LDAP 관리자 패스워드
              value: "admin"
            - name: LDAP_CONFIG_PASSWORD
              value: "admin"
        - name: phpldapadmin
          image: osixia/phpldapadmin:0.9.0
          ports:
            - containerPort: 80
              name: phpldapadmin
          env:
            - name: PHPLDAPADMIN_HTTPS
              value: "false"
            - name: PHPLDAPADMIN_LDAP_HOSTS
              value: "openldap"   # LDAP hostname inside cluster
---
apiVersion: v1
kind: Service
metadata:
  name: openldap
  namespace: openldap
spec:
  selector:
    app: openldap
  ports:
    - name: phpldapadmin
      port: 80
      targetPort: 80
      nodePort: 30001
    - name: ldap
      port: 389
      targetPort: 389
    - name: ldaps
      port: 636
      targetPort: 636
  type: NodePort
EOF

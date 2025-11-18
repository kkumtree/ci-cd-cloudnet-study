#!/bin/bash  
  
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout openssl-x509-output/argocd.example.com.key \
  -out openssl-x509-output/argocd.example.com.crt \
  -subj "/CN=argocd.example.com/O=argocd"

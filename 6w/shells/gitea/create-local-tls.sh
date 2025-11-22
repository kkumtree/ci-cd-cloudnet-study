#!/bin/bash  
  
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout openssl-x509-output/kkumtree-ms-7a34.panda-ule.ts.net.key \
  -out openssl-x509-output/kkumtree-ms-7a34.panda-ule.ts.net.crt \
  -subj "/CN=kkumtree-ms-7a34.panda-ule.ts.net/O=kkumtree"

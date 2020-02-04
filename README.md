Assuming your domain is example.com

and masters hostnames are:
kube01-master01
kube01-master02
kube01-master03

masters have following internal IP addresses:
10.0.0.2
10.0.0.3
10.0.0.4
and following external IP addresses:
88.87.86.2
88.87.86.3
88.87.86.4

***Generation of certificates***
```
#!/bin/bash

openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=Kubernetes/OU=CA/CN=Kubernetes" -days 3650 -out ca.crt

cat > apiserver.csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = kubernetes

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
DNS.6 = kube01.example.com
DNS.7 = kube01-master01.example.com
DNS.8 = kube01-master02.example.com
DNS.9 = kube01-master03.example.com
IP.1 = 127.0.0.1
IP.2 = 10.0.0.2
IP.3 = 10.0.0.3
IP.4 = 10.0.0.4
IP.5 = 88.87.86.2
IP.6 = 88.87.86.3
IP.7 = 88.87.86.4
IP.8 = 172.20.0.1

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF

openssl genrsa -out apiserver.key 2048
openssl req -new -key apiserver.key -out apiserver.csr -config apiserver.csr.conf
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out apiserver.crt -days 3650 -extensions v3_ext -extfile apiserver.csr.conf

openssl req -new -newkey rsa:2048 -nodes -keyout controller-manager.key -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=system:kube-controller-manager/OU=Kubernetes/CN=system:kube-controller-manager" -out controller-manager.csr
openssl x509 -req -in controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out controller-manager.crt -days 3650

openssl req -new -newkey rsa:2048 -nodes -keyout scheduler.key -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=system:kube-scheduler/OU=Kubernetes/CN=system:kube-scheduler" -out scheduler.csr
openssl x509 -req -in scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out scheduler.crt -days 3650

openssl req -new -newkey rsa:2048 -nodes -keyout kube-proxy.key -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=system:node-proxier/OU=Kubernetes/CN=system:kube-proxy" -out kube-proxy.csr
openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-proxy.crt -days 3650

openssl req -new -newkey rsa:2048 -nodes -keyout bootstrap.key -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=system:bootstrappers/OU=Kubernetes/CN=system:bootstrap:default" -out bootstrap.csr
openssl x509 -req -in bootstrap.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out bootstrap.crt -days 3650

openssl req -new -newkey rsa:2048 -nodes -keyout kube01-master01.i.example.com.key -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=system:nodes/OU=Kubernetes/CN=system:node:kube01-master01.i.example.com" -out kube01-master01.i.example.com.csr
openssl x509 -req -in kube01-master01.i.example.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube01-master01.i.example.com.crt -days 3650

openssl req -new -newkey rsa:2048 -nodes -keyout kube01-master02.i.example.com.key -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=system:nodes/OU=Kubernetes/CN=system:node:kube01-master02.i.example.com" -out kube01-master02.i.example.com.csr
openssl x509 -req -in kube01-master02.i.example.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube01-master02.i.example.com.crt -days 3650

openssl req -new -newkey rsa:2048 -nodes -keyout kube01-master03.i.example.com.key -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=system:nodes/OU=Kubernetes/CN=system:node:kube01-master03.i.example.com" -out kube01-master03.i.example.com.csr
openssl x509 -req -in kube01-master03.i.example.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube01-master03.i.example.com.crt -days 3650

openssl req -new -newkey rsa:2048 -nodes -keyout cluster-admin.key -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=system:masters/OU=Test/CN=cluster-admin" -out cluster-admin.csr
openssl x509 -req -in cluster-admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out cluster-admin.crt -days 3650
```

***Master hiera example***

```
---
k8s::version: '1.10.7'
k8s::apiservers:
  kube01-master01: '10.0.0.2:6443'
  kube01-master02: '10.0.0.3:6443'
  kube01-master03: '10.0.0.4:6443'
k8s::internal_interface: 'eth1'
k8s::etcd_urls: 'http://10.0.0.2:2379,http://10.0.0.3:2379,http://10.0.0.4:2379'
k8s::service_cluster_ip_range: '172.20.0.0/16'
k8s::cluster_cidr: '172.18.0.0/15'
k8s::cluster_dns: '172.20.0.10'
k8s::node_cidr_mask_size: '21'
k8s::node_labels: 'kubernetes.io/role=master,node-role.kubernetes.io/master='
k8s::node_taints: 'node-role.kubernetes.io/master=:NoSchedule,node-role.kubernetes.io/master=:NoExecute,kubernetes.io/role=master:NoSchedule,kubernetes.io/role=master:NoExecute'
k8s::ca_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::ca_key: |
  -----BEGIN RSA PRIVATE KEY-----
  ...
  -----END RSA PRIVATE KEY-----
k8s::apiserver_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::apiserver_key: |
  -----BEGIN RSA PRIVATE KEY-----
  ...
  -----END RSA PRIVATE KEY-----
k8s::controller_manager_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::controller_manager_key: |
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
k8s::scheduler_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::scheduler_key: |
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
k8s::service_accounts_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::service_accounts_key: |
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
k8s::kube_proxy_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::kube_proxy_key: |
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
k8s::kubelet_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::kubelet_key: |
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
```

***Worker hiera example***
```
---
k8s::version: '1.10.7'
k8s::apiservers:
  kube01-master01: '10.0.0.2:6443'
  kube01-master02: '10.0.0.3:6443'
  kube01-master03: '10.0.0.4:6443'
k8s::internal_interface: 'eth1'
k8s::cluster_cidr: '172.18.0.0/15'
k8s::cluster_dns: '172.20.0.10'
k8s::node_labels: 'kubernetes.io/role=border,node-role.kubernetes.io/border='
k8s::ca_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::kube_proxy_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::kube_proxy_key: |
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
k8s::bootstrap_crt: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
k8s::bootstrap_key: |
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
```

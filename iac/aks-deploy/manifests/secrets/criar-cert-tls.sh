#!/bin/bash

cat > all-cert.cnf <<EOF
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[dn]
CN = *.marcio-datamaster.com

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.marcio-datamaster.com
DNS.2 = *.datamaster.internal

[ext]
subjectAltName = @alt_names
EOF

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout certificado.key \
  -out certificado.crt \
  -config all-cert.cnf \
  -extensions 'ext'


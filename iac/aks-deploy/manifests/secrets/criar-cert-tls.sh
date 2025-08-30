#!/bin/bash

#Geração de certificado
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout certificado.key \
  -out certificado.crt \
  -subj "/C=BR/ST=SP/L=São Paulo/O=Datamaster/CN=dataplatform.marcio_datamaster.com.br"

openssl pkcs12 -export \
  -out certificado.pfx \
  -inkey certificado.key \
  -in certificado.crt \
  -password pass:12345678


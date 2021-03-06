#!/bin/bash

cd /php/tmp

DOMAIN="$1"
if [ -z "$DOMAIN" ]; then
  echo "Usage: $(basename $0) <domain>"
  exit 11
fi
fail_if_error() {
  [ $1 != 0 ] && {
    unset PASSPHRASE
    exit 10
  }
}

# Generate a passphrase
export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)
subj="
C=VN
ST=Hanoi
O=F5Networks
localityName=Hanoi
commonName=$DOMAIN
organizationalUnitName=F5ASEAN
emailAddress=biennt0979@gmail.com
"

# aenerate the server private key
openssl genrsa -writerand /tmp/ranfile -des3 -out $DOMAIN.key -passout env:PASSPHRASE 2048
 fail_if_error $?

# Generate the CSR
openssl req \
  -new \
  -batch \
  -subj "$(echo -n "$subj" | tr "\n" "/")" \
  -key $DOMAIN.key \
  -out $DOMAIN.csr \
  -passin env:PASSPHRASE
fail_if_error $?
cp $DOMAIN.key $DOMAIN.key.org
fail_if_error $?

# Strip the password so we don't have to type it every time we restart Apache
openssl rsa -in $DOMAIN.key.org -out $DOMAIN.key -passin env:PASSPHRASE
fail_if_error $?

# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
fail_if_error $?
mv $DOMAIN.* /etc/nginx/ssl/certs/

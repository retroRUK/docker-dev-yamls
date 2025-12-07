#!/bin/bash

common_name=$1
ip_sans=$2

while [ -z "$common_name" ]; do
    read -p "Common name is required: " common_name
done

while [ -z "$ip_sans" ]; do
    read -p "A least one IP is required: " ip_sans
done

root_token=$(jq -r '.root_token' init.json)
docker compose exec -T openbao bao login -tls-skip-verify "$root_token" < /dev/null

# Issue Production Certificate
echo "----- Issue Production Certificate -----"
docker compose exec -T openbao bao write -tls-skip-verify -format=json pki-prod/issue/production \
    common_name="$common_name" \
    ip_sans="$ip_sans" \
    > cert.json

jq -r '.data.certificate' cert.json > ../certs/$common_name.crt
jq -r '.data.private_key' cert.json > ../certs/$common_name.key

rm cert.json
#!/bin/bash

root_token=$(jq -r '.root_token' init.json)
docker compose exec -T openbao bao login "$root_token" < /dev/null

# Issue Development Certificate
echo "----- Issue Development Certificate -----"
docker compose exec -T openbao bao write -format=json pki-dev/issue/development \
    common_name="localhost" \
    ip_sans="127.0.0.1" \
    > localhost_cert.json

jq -r '.data.certificate' localhost_cert.json > ../certs/cert.pem
jq -r '.data.private_key' localhost_cert.json > ../certs/key.pem
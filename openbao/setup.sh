#!/bin/bash



docker compose exec --user=root openbao chown -R openbao:openbao /openbao/

docker compose exec -T openbao bao operator init \
    -key-shares=5 \
    -key-threshold=3 \
    -tls-skip-verify \
    -format=json > init.json

jq -r '.unseal_keys_b64[]' init.json | while read -r key; do
    echo "$key"
    docker compose exec -T openbao bao operator unseal -tls-skip-verify "$key" < /dev/null
done

root_token=$(jq -r '.root_token' init.json)
docker compose exec -T openbao bao login -tls-skip-verify "$root_token" < /dev/null

# Setting Up Development PKI
echo "----- Setting Up Development PKI -----"
docker compose exec -T openbao bao secrets enable -tls-skip-verify -path=pki-dev pki
docker compose exec -T openbao bao secrets tune -tls-skip-verify -max-lease-ttl=87600h pki-dev
docker compose exec -T openbao bao write -tls-skip-verify -format=json pki-dev/root/generate/internal \
    common_name="Development CA" \
    ttl=87600h \
    > dev_ca_cert.json

jq -r '.data.certificate' dev_ca_cert.json > ../certs/development.ca.pem
rm dev_ca_cert.json

docker compose exec -T openbao bao write -tls-skip-verify pki-dev/config/urls \
    issuing_certificates="https://localhost:8200/v1/pki-dev/ca" \
    crl_distribution_points="https://localhost:8200/v1/pki-dev/crl"

docker compose exec -T openbao bao write -tls-skip-verify pki-dev/roles/development \
    allowed_domains="localhost,127.0.0.1" \
    allow_localhost=true \
    allow_ip_sans=true \
    allow_subdomains=true \
    max_ttl=8760h \
    key_usage="DigitalSignature,KeyEncipherment" \
    ext_key_usage="ServerAuth,ClientAuth"

# Setting Up Production PKI
echo "----- Setting Up Production PKI -----"
docker compose exec -T openbao bao secrets enable -tls-skip-verify -path=pki-prod pki
docker compose exec -T openbao bao secrets tune -tls-skip-verify -max-lease-ttl=87600h pki-prod
docker compose exec -T openbao bao write -tls-skip-verify -format=json pki-prod/root/generate/internal \
    common_name="Production CA" \
    ttl=87600h \
    > prod_ca_cert.json

jq -r '.data.certificate' prod_ca_cert.json > ../certs/production.ca.pem
rm prod_ca_cert.json

docker compose exec -T openbao bao write -tls-skip-verify pki-prod/config/urls \
    issuing_certificates="https://localhost:8200/v1/pki-prod/ca" \
    crl_distribution_points="https://localhost:8200/v1/pki-prod/crl"

docker compose exec -T openbao bao write -tls-skip-verify pki-prod/roles/production \
    allowed_domains="angela.com" \
    allow_localhost=true \
    allow_ip_sans=true \
    allow_bare_domains=true \
    allow_subdomains=true \
    max_ttl=8760h \
    key_usage="DigitalSignature,KeyEncipherment" \
    ext_key_usage="ServerAuth,ClientAuth"

# Issue Development Certificate
echo "----- Issue Development Certificate -----"
docker compose exec -T openbao bao write -tls-skip-verify -format=json pki-dev/issue/development \
    common_name="localhost" \
    ip_sans="127.0.0.1" \
    > localhost_cert.json

jq -r '.data.certificate' localhost_cert.json > ../certs/cert.pem
jq -r '.data.private_key' localhost_cert.json > ../certs/key.pem

echo "Add development.ca.pem to your CA trust"

docker compose restart

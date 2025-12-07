#!/bin/bash

jq -r '.unseal_keys_b64[]' init.json | while read -r key; do
    echo "$key"
    docker compose exec -T openbao bao operator unseal -tls-skip-verify "$key" < /dev/null
done
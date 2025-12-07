storage "file" {
  path = "/openbao/data"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = 0
  tls_cert_file = "/openbao/certs/cert.pem"
  tls_key_file  = "/openbao/certs/key.pem"
  tls_min_version = "tls12"
}

api_addr = "https://127.0.0.1:8200"
cluster_addr = "https://12.7.0.1:8201"

ui = true

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname = false
}

log_level = "info"
log_format = "json"

max_lease_ttl = "87600h"
default_lease_ttl = "87600h"
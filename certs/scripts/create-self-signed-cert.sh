#!/bin/bash

DOMAIN="${1:-localhost}"
DAYS="${2:-365}"
OUTPUT_DIR="${3:-../}"

mkdir -p "$OUTPUT_DIR"

echo "Creating self-signed certificate for: $DOMAIN"
echo "Valid for: $DAYS days"
echo "Output directory: $OUTPUT_DIR"

# Generate private key and certificate in one command
openssl req -x509 -newkey rsa:4096 -nodes \
  -keyout "$OUTPUT_DIR/key.pem" \
  -out "$OUTPUT_DIR/cert.pem" \
  -days "$DAYS" \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN" \
  -addext "subjectAltName=DNS:$DOMAIN,DNS:*.$DOMAIN,IP:127.0.0.1"

echo ""
echo "  Certificate created successfully!"
echo "  Private Key: $OUTPUT_DIR/key.pem"
echo "  Certificate: $OUTPUT_DIR/cert.pem"
echo ""
echo "To view certificate details:"
echo "  openssl x509 -in $OUTPUT_DIR/cert.pem -text -noout"
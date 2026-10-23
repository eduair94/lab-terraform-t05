#!/bin/bash
# Seccion-1 "Full Manual": los MISMOS clics de la consola, pero con AWS CLI contra moto.
# Uso: bash manual-steps.sh    (moto corriendo en localhost:5000)
set -euo pipefail
export AWS_ACCESS_KEY_ID=testing AWS_SECRET_ACCESS_KEY=testing AWS_DEFAULT_REGION=us-east-1
aws() { command aws --endpoint-url http://localhost:5000 "$@"; }
BUCKET=mybucket-1045

# 02-01 Crear bucket
aws s3api create-bucket --bucket "$BUCKET"
# 02-02 Habilitar Static website hosting
aws s3 website "s3://$BUCKET" --index-document index.html --error-document error.html
# 02-03 Quitar "Block all public access"
aws s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration \
  BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false
# 02-04 Bucket policy de lectura publica
aws s3api put-bucket-policy --bucket "$BUCKET" --policy file://policy-public-read-access-for-website.json
# 02-05 Subir index.html
aws s3 cp index.html "s3://$BUCKET/index.html" --content-type text/html
# 02-06 Probar
curl -s "http://localhost:5000/$BUCKET/index.html" | grep "<h1>"
echo "OK - 5 pasos manuales. Limpieza: aws s3 rb s3://$BUCKET --force"

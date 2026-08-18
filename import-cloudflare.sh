#!/bin/bash
# Helper script to automatically fetch Cloudflare record IDs and import them into Terraform

set -e

ZONE_ID="a8d511407e9dcaf145b121d7a06a2537"

TOKEN="${TF_VAR_cloudflare_api_token}"

if [ -z "$TOKEN" ]; then
  TOKEN=$(pass cloudflare/swapwithus/api-token 2>/dev/null || pass swapwithus/api 2>/dev/null || echo "")
fi


if [ -z "$TOKEN" ]; then
  echo "Error: Could not retrieve Cloudflare API Token."
  echo "Please set it with: export TF_VAR_cloudflare_api_token=\$(pass cloudflare/swapwith/api-token)"
  exit 1
fi

export TF_VAR_cloudflare_api_token="$TOKEN"

echo "1. Initializing Terraform..."
terraform init

echo "2. Fetching DNS Record IDs automatically from Cloudflare..."
RECORDS_JSON=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json")

# Parse JSON using python3 for accuracy
IDS=$(python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    records = data.get("result", [])
    root_id, www_id, cdn_id = "", "", ""
    for r in records:
        name = r.get("name", "")
        rtype = r.get("type", "")
        if name == "swapwithus.com" and rtype == "A":
            root_id = r.get("id")
        elif name == "www.swapwithus.com":
            www_id = r.get("id")
        elif name == "cdn.swapwithus.com":
            cdn_id = r.get("id")
    print(f"{root_id},{www_id},{cdn_id}")
except Exception as e:
    print(",,")
' <<< "$RECORDS_JSON")

ROOT_ID=$(echo "$IDS" | cut -d',' -f1)
WWW_ID=$(echo "$IDS" | cut -d',' -f2)
CDN_ID=$(echo "$IDS" | cut -d',' -f3)

echo "   Root Record ID (@): ${ROOT_ID:-Not Found}"
echo "   WWW Record ID:     ${WWW_ID:-Not Found}"
echo "   CDN Record ID:     ${CDN_ID:-Not Found}"
echo ""

echo "3. Importing DNS records into Terraform..."
if [ -n "$ROOT_ID" ]; then
  echo "Importing root (@)..."
  terraform import cloudflare_record.root "${ZONE_ID}/${ROOT_ID}" || true
fi

if [ -n "$WWW_ID" ]; then
  echo "Importing www..."
  terraform import cloudflare_record.www "${ZONE_ID}/${WWW_ID}" || true
fi

if [ -n "$CDN_ID" ]; then
  echo "Importing cdn..."
  terraform import cloudflare_record.cdn "${ZONE_ID}/${CDN_ID}" || true
fi

echo ""
echo "========================================="
echo "Cloudflare Import Complete!"
echo "Run 'terraform plan' to verify."
echo "========================================="

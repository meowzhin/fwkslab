#!/bin/bash

CF_API_TOKEN='--TOKEN--'
CF_API_URL='https://api.cloudflare.com/client/v4'

list_zones() {
  curl -s -X GET "$CF_API_URL/zones" \
       -H "Authorization: Bearer $CF_API_TOKEN" \
       -H "Content-Type: application/json" | jq -r '.result[].id'
}

list_dns_records() {
  local zone_id=$1
  curl -s -X GET "$CF_API_URL/zones/$zone_id/dns_records" \
       -H "Authorization: Bearer $CF_API_TOKEN" \
       -H "Content-Type: application/json" | jq -r '.result[].id'
}

delete_dns_record() {
  local zone_id=$1
  local record_id=$2
  curl -s -X DELETE "$CF_API_URL/zones/$zone_id/dns_records/$record_id" \
       -H "Authorization: Bearer $CF_API_TOKEN" \
       -H "Content-Type: application/json"
}

delete_zone() {
  local zone_id=$1
  curl -s -X DELETE "$CF_API_URL/zones/$zone_id" \
       -H "Authorization: Bearer $CF_API_TOKEN" \
       -H "Content-Type: application/json"
}

ZONE_IDS=$(list_zones)

for ZONE_ID in $ZONE_IDS; do
  echo "Processing zone: $ZONE_ID"

  DNS_RECORD_IDS=$(list_dns_records $ZONE_ID)

  for RECORD_ID in $DNS_RECORD_IDS; do
    echo "Deleting DNS record: $RECORD_ID from zone: $ZONE_ID"
    delete_dns_record $ZONE_ID $RECORD_ID
  done

  echo "Deleting zone: $ZONE_ID"
  delete_zone $ZONE_ID
done

echo "All DNS records and zones have been deleted."
#!/bin/bash

while IFS="=" read -r key value; do
  case "$key" in
    name) NAME="$value" ;;
    resource_group) RG="$value" ;;
  esac
done

FABRIC_JSON=$(az fabric workspace show \
  --name "$NAME" \
  --resource-group "$RG" \
  --query "{id:id, principalId:identity.principalId}" \
  -o json)

echo "$FABRIC_JSON"


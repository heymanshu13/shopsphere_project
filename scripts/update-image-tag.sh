#!/bin/bash

set -e

TAG="$1"

if [ -z "$TAG" ]; then
    echo "Usage: ./scripts/update-image-tag.sh <BUILD_NUMBER>"
    echo "Example: ./scripts/update-image-tag.sh 23"
    exit 1
fi

SERVICES=(
    "user-service"
    "product-service"
    "order-service"
    "payment-service"
    "notification-service"
)

for SERVICE in "${SERVICES[@]}"; do

    FILE="kubernetes/base/${SERVICE}.yaml"

    if [ ! -f "$FILE" ]; then
        echo "ERROR: File not found: $FILE"
        exit 1
    fi

    echo "Updating ${SERVICE} -> :${TAG}"

    sed -i -E \
        "s|(shopsphere-${SERVICE}:)[0-9]+|\1${TAG}|g" \
        "$FILE"

done

echo ""
echo "========================================"
echo "All image tags updated to :${TAG}"
echo "========================================"

echo ""
echo "Current images:"
grep -R "image:" kubernetes/base/*.yaml

#!/bin/bash
set -euo pipefail

# Check if required environment variables are set
if [[ -z "${SITEMAP_URL:-}" ]]; then
    echo "Error: SITEMAP_URL environment variable is not set"
    exit 1
fi

if [[ -z "${DATA_DIR:-}" ]]; then
    echo "Error: DATA_DIR environment variable is not set"
    exit 1
fi

# Create data directory if it doesn't exist
mkdir -p "${DATA_DIR}"

# Fetch the sitemap
curl -s "$SITEMAP_URL" -o "${DATA_DIR}/sitemap.xml"

echo "Sitemap fetched successfully to ${DATA_DIR}/sitemap.xml"
#!/bin/bash
set -euo pipefail

# Check if required environment variables are set
if [[ -z "${DATA_DIR:-}" ]]; then
    echo "Error: DATA_DIR environment variable is not set"
    exit 1
fi

if [[ -z "${BASE_DIR:-}" ]]; then
    echo "Error: BASE_DIR environment variable is not set"
    exit 1
fi

# Check if sitemap file exists
if [[ ! -f "${DATA_DIR}/sitemap.xml" ]]; then
    echo "Error: Sitemap file not found at ${DATA_DIR}/sitemap.xml"
    echo "Please run 'make fetch_sitemap' first"
    exit 1
fi

echo "Parsing sitemap from ${DATA_DIR}/sitemap.xml"

xq -r '.sitemapindex.sitemap | .[].loc' "${DATA_DIR}/sitemap.xml" | while read -r url; do
    echo "Processing URL: $url"
    topic_filename="topic_${url##*/}"
    if [[ $topic_filename == "topic_sitemap.xml" ]]; then
        continue
    fi
    curl -s "$url" -o "${DATA_DIR}/$topic_filename"
done
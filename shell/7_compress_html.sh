#!/bin/bash
set -euo pipefail

echo "Compressing html directory..."

if [[ -z "${DATA_DIR:-}" ]]; then
    echo "Error: DATA_DIR environment variable is not set"
    exit 1
fi

if [[ -z "${HTML_DIR:-}" ]]; then
    echo "Error: HTML_DIR environment variable is not set"
    exit 1
fi

cd "${HTML_DIR}" && tar -czf "geeknews_$(date +%Y%m%d).tgz" *.html && rm *.html

echo "Compressing html directory done" 
#!/bin/bash
set -euo pipefail

echo "Treating too many request..."

if [[ -z "${HTML_DIR:-}" ]]; then
    echo "Error: HTML_DIR environment variable is not set"
    exit 1
fi

wc -l ${HTML_DIR}/*.html \
| awk '$1 < 100 { print $2 }' \
| cut -d '.' -f 1 \
| cut -d '/' -f 2 \
| awk -v html_dir="${HTML_DIR}" '{ printf "curl https://news.hada.io/topic?id=%s -o %s/%s.html\n", $1, html_dir, $1 }' \
| bash

echo "Treating too many request done"
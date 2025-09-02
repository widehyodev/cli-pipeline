#!/bin/bash
set -euo pipefail

echo "Making topic CSV..."

if [[ -z "${DATA_DIR:-}" ]]; then
    echo "Error: DATA_DIR environment variable is not set"
    exit 1
fi

# Create data directory if it doesn't exist
mkdir -p "${DATA_DIR}"

# Create topic CSV
rm -f "${DATA_DIR}/topics.csv"
touch "${DATA_DIR}/topics.csv"
# add header
echo "url,lastmod" >> "${DATA_DIR}/topics.csv"

# loop through all topic files
find "${DATA_DIR}" -name "topic_*.xml" | sort -n | while read -r file; do
    echo "Processing $file"
    xq -r '.urlset
    | .url[]
    | select(.loc | contains("topic"))
    | [.loc, .lastmod]
    | @csv
    ' "${file}" | sed 's/"//g' >> "${DATA_DIR}/topics.csv"
done

echo "Topic CSV made successfully to ${DATA_DIR}/topics.csv"
#!/bin/bash
set -euo pipefail

echo "Parsing HTML..."

if [[ -z "${HTML_DIR:-}" ]]; then
    echo "Error: HTML_DIR environment variable is not set"
    exit 1
fi

parsed_html_dir="${DATA_DIR}/sequential_parsed"
# create parsed directory if it doesn't exist
mkdir -p "${parsed_html_dir}"

echo "[SEQUENTIAL] Parsing HTML..."
# extract content from html file
start=$(date +%s%3N)
find "${HTML_DIR}" -name "*.html" | while read -r html_file; do
    htmlq "div.topictitle.link a, span#topic_contents, span.comment_contents" --filename "$html_file" \
    > "${parsed_html_dir}/parsed_$(basename $html_file)"
done
end=$(date +%s%3N)
elapsed=$((end - start))
echo "Time taken: ${elapsed} milliseconds"

echo "Parsing HTML done"
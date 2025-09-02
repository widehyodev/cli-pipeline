#!/bin/bash
set -euo pipefail

echo "Parsing HTML..."

if [[ -z "${HTML_DIR:-}" ]]; then
    echo "Error: HTML_DIR environment variable is not set"
    exit 1
fi

parsed_html_dir="${DATA_DIR}/parallel_parsed"
# create parsed directory if it doesn't exist
mkdir -p "${parsed_html_dir}"

echo "[PARALLEL] Parsing HTML..."
nproc=$(nproc)

export parsed_html_dir
# extract content from html file
start=$(date +%s%3N)
echo "Extracting content from html file"

find "${HTML_DIR}" -name "*.html" | \
parallel --env parsed_html_dir -j "$nproc" '
    htmlfile="{}"
    htmlq "div.topictitle.link a, span#topic_contents, span.comment_contents" --filename "$htmlfile" \
    > "${parsed_html_dir}/parsed_$(basename "$htmlfile")"
'

end=$(date +%s%3N)
elapsed=$((end - start))
echo "Time taken: ${elapsed} milliseconds"

echo "Parsing HTML done"
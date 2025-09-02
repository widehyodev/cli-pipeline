#!/bin/bash
set -euo pipefail

echo "Parsing HTML..."

if [[ -z "${HTML_DIR:-}" ]]; then
    echo "Error: HTML_DIR environment variable is not set"
    exit 1
fi

parsed_html_dir="${DATA_DIR}/xargs_parsed"
# create parsed directory if it doesn't exist
mkdir -p "${parsed_html_dir}"

echo "[XARGS] Parsing HTML..."
nproc=$(nproc)
# extract content from html file
start=$(date +%s%3N)
echo "Extracting content from html file"
 find "${HTML_DIR}" -name "*.html" | 
 xargs -P "$nproc" -I {} bash -c '
     htmlfile="$1"
     parsed_html_dir="$2"
     htmlq "div.topictitle.link a, span#topic_contents, span.comment_contents" --filename "$htmlfile" \
     > "${parsed_html_dir}/parsed_$(basename $htmlfile)"
 ' _ {} "$parsed_html_dir" 
end=$(date +%s%3N)
elapsed=$((end - start))
echo "Time taken: ${elapsed} milliseconds"

echo "Parsing HTML done"
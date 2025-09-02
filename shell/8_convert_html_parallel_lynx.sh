#!/bin/bash
set -euo pipefail

echo "Converting html to markdown using xargs and lynx..."

if [[ -z "${PARSED_HTML_DIR:-}" ]]; then
    echo "Error: PARSED_HTML_DIR environment variable is not set"
    exit 1
fi

if [[ -z "${RESULT_DIR:-}" ]]; then
    echo "Error: RESULT_DIR environment variable is not set"
    exit 1
fi

nproc=$(nproc)

parsed_html_dir="${PARSED_HTML_DIR}"
result_dir="${RESULT_DIR}"
tmpfs_dir="${TMPFS_DIR}"

echo "[xargs, lynx] Converting html to csv file..."
start=$(date +%s%3N)
find "${parsed_html_dir}" -name "*.html" -printf "%f\n" |
sort -n |
xargs -P "${nproc}" -I {} bash -c '
    html_file="$1"
    parsed_html_dir="$2"
    tmpfs_dir="$3"

    id=$(basename ${html_file} .html | cut -d "_" -f 2)
    url="https://news.hada.io/topic?id=${id}"
    title=$(htmlq "a.bold.ud h1" -t -f "${parsed_html_dir}/${html_file}")
    content=$(LANG=ko_KR.UTF-8 lynx -assume_charset=utf-8 -display_charset=utf-8 -dump -nolist -width=1000 "${parsed_html_dir}/${html_file}" |
    jq -Rs "." | jq -r "[.] | @csv")
    echo "\"${id}\",\"${url}\",\"${title}\",${content}" > "${tmpfs_dir}/${id}.csv"
' _ {} "$parsed_html_dir" "$tmpfs_dir"
ls "${tmpfs_dir}" | sort -n | xargs -I @ cat "${tmpfs_dir}/@" > "${result_dir}/xargs_lynx_out.csv"
end=$(date +%s%3N)
elapsed=$((end - start))
echo "[xargs, lynx] Time taken: ${elapsed} milliseconds"

echo "${result_dir}/xargs_lynx_out.csv done"
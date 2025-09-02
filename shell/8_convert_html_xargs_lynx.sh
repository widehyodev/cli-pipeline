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

if [[ -z "${TMPFS_DIR:-}" ]]; then
    echo "Error: TMPFS_DIR environment variable is not set"
    exit 1
fi

nproc=$(nproc)

parsed_html_dir="${PARSED_HTML_DIR}"
result_dir="${RESULT_DIR}"
tmpfs_dir="${TMPFS_DIR}"

# Check if TMPFS_DIR is actually mounted as tmpfs
echo "Checking filesystem type for ${tmpfs_dir}..."
if mountpoint -q "${tmpfs_dir}" 2>/dev/null; then
    fs_type=$(findmnt -n -o FSTYPE "${tmpfs_dir}" 2>/dev/null || echo "unknown")
    if [[ "$fs_type" == "tmpfs" ]]; then
        echo "✓ TMPFS detected: ${tmpfs_dir} is mounted as tmpfs"
        tmpfs_size=$(findmnt -n -o SIZE "${tmpfs_dir}" 2>/dev/null || echo "unknown")
        tmpfs_avail=$(findmnt -n -o AVAIL "${tmpfs_dir}" 2>/dev/null || echo "unknown")
        echo "  Size: ${tmpfs_size}, Available: ${tmpfs_avail}"
    else
        echo "⚠ WARNING: ${tmpfs_dir} is mounted but NOT as tmpfs (type: ${fs_type})"
        echo "  Performance may be slower than expected"
    fi
else
    echo "⚠ WARNING: ${tmpfs_dir} is NOT a mount point"
    echo "  Using regular filesystem - performance may be slower"
    # Create directory if it doesn't exist
    mkdir -p "${tmpfs_dir}"
fi

echo "[xargs, lynx] Converting html to csv file..."
start=$(date +%s%3N)
find "${parsed_html_dir}" -name "*.html" -printf "%f\n" |
sort -n |
xargs -P "${nproc}" -I {} bash -c '
    html_file="$1"
    parsed_html_dir="$2"
    tmpfs_dir="$3"

    id=$(basename "${html_file}" .html | cut -d "_" -f 2)
    url="https://news.hada.io/topic?id=${id}"
    title=$(htmlq "a.bold.ud h1" -t -f "${parsed_html_dir}/${html_file}")
    content=$(LANG=ko_KR.UTF-8 lynx -assume_charset=utf-8 -display_charset=utf-8 -dump -nolist -width=1000 "${parsed_html_dir}/${html_file}" |
    jq -Rs "." | jq -r "[.] | @csv")
    echo "\"${id}\",\"${url}\",\"${title}\",${content}" > "${tmpfs_dir}/${id}.csv"
' _ {} "$parsed_html_dir" "$tmpfs_dir"
echo "reducing csv files..."
find "${tmpfs_dir}" -name "*.csv" | sort -n | xargs -I @ cat @ > "${result_dir}/xargs_lynx_out.csv"
echo "compressing csv files..."
tar --zstd -cf "${result_dir}/xargs_lynx_out.zst" "${tmpfs_dir}"/*.csv
end=$(date +%s%3N)
elapsed=$((end - start))
echo "[xargs, lynx] Time taken: ${elapsed} milliseconds"

cleanup() {
    echo "Cleaning up temp files..."
    rm -f "${tmpfs_dir}"/*.csv
}
trap cleanup EXIT

echo "${result_dir}/xargs_lynx_out.csv done"
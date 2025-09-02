#!/bin/bash
set -euo pipefail
source ../.env
# 설정
target_dir=${1:=${DATA_DIR}/split/sp_128}
# target_dir=${1:=${DATA_DIR}/split/sp_1024}
result_dir=${2:=${RESULT_DIR}}
outfile="${result_dir}/bulk_data.csv"
out_xargs="${result_dir}/bulk_xargs.csv"
out_parallel="${result_dir}/bulk_parallel.csv"
selector=${3:='span#topic_contents, span.comment_contents'}

# URL 추출 함수
url_from_filename() {
    local f="$1"
    echo "https://news.hada.io/topic?id=$(basename "${f%%.*}")"
}

# 실제 파일 처리 로직
process_file() {
    local fullpath="$1"
    local f="$(basename "$fullpath")"
    local url title content

    url=$(url_from_filename "$f")
    title=$(htmlq "div.topictitle.link h1" -t -f "$fullpath")
    content=$(htmlq "div.topictitle.link a, span#topic_contents, span.comment_contents" -f "$fullpath" |
        LANG=ko_KR.UTF-8 lynx -assume_charset=utf-8 -display_charset=utf-8 -dump -nolist -width=1000 -stdin |
        jq -Rs "." | jq -r "[.] | @csv")
    echo "\"$url\",\"$title\",$content"
}

# 방식별 실행
run_sequential() {
    echo "[Sequential execution]"
    local start end elapsed
    start=$(date +%s%3N)

    find "$target_dir" -type f -name "*.html" -printf "%f\n" | sort -n |
    while IFS= read -r f; do
        process_file "$target_dir/$f"
    done > "$outfile"

    end=$(date +%s%3N)
    elapsed=$((end - start))
    echo "Sequential elapsed: ${elapsed} ms"
}

run_xargs() {
    echo "[xargs execution]"
    local start end elapsed
    local nproc="${1:-$(nproc)}"
    start=$(date +%s%3N)

    find "$target_dir" -type f -name "*.html" -printf "%f\n" |
    xargs -P "$nproc" -I {} bash -c '
        f="$1"; target_dir="$2"
        fullpath="$target_dir/$f"
        url="https://news.hada.io/topic?id=$(basename "${f%%.*}")"
        title=$(htmlq "div.topictitle.link h1" -t -f "$fullpath")
        content=$(htmlq "div.topictitle.link a, span#topic_contents, span.comment_contents" -f "$fullpath" |
            LANG=ko_KR.UTF-8 lynx -assume_charset=utf-8 -display_charset=utf-8 -dump -nolist -width=1000 -stdin |
            jq -Rs "." | jq -r "[.] | @csv")
        echo "\"$url\",\"$title\",$content"
    ' _ {} "$target_dir" > "$out_xargs"

    end=$(date +%s%3N)
    elapsed=$((end - start))
    echo "xargs elapsed: ${elapsed} ms"
}

run_parallel() {
    echo "[GNU parallel execution]"
    local start end elapsed
    local nproc="${1:-$(nproc)}"
    export target_dir
    start=$(date +%s%3N)

    find "$target_dir" -type f -name "*.html" -printf "%f\n" |
    parallel --env target_dir -j"$nproc" '
        f="{}"
        fullpath="$target_dir/$f"
        url="https://news.hada.io/topic?id=$(basename "${f%%.*}")"
        title=$(htmlq "div.topictitle.link h1" -t -f "$fullpath")
        content=$(htmlq "div.topictitle.link a, span#topic_contents, span.comment_contents" -f "$fullpath" |
            LANG=ko_KR.UTF-8 lynx -assume_charset=utf-8 -display_charset=utf-8 -dump -nolist -width=1000 -stdin |
            jq -Rs "." | jq -r "[.] | @csv")
        echo "\"$url\",\"$title\",$content"
    ' > "$out_parallel"

    end=$(( $(date +%s%3N) ))
    elapsed=$((end - start))
    echo "parallel elapsed: ${elapsed} ms"
}

# 실행
run_sequential
run_xargs $(nproc)
run_parallel $(nproc)
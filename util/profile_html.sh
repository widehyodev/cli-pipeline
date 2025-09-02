#!/bin/bash
# profile convert text
set -euo pipefail
source ../.env

target_dir=${1:=${DATA_DIR}/split/sp_128}
# target_dir=${1:=${DATA_DIR}/split/sp_1024}
result_dir=${2:=${RESULT_DIR}}
selector=${3:='span#topic_contents, span.comment_contents'}

measure_time_ms() {
    local cmd="$1"
    local start end elapsed
    start=$(date +%s%3N)  # milliseconds
    eval "$cmd"
    end=$(date +%s%3N)
    elapsed=$((end - start))
    echo "$elapsed"
}

profile_convert_tool() {
    local tool="$1"
    local htmlfile="$2"

    if [[ "$tool" == "pandoc" ]]; then
        measure_time_ms "pandoc -f html -t markdown < \"$htmlfile\" > /dev/null"
    elif [[ "$tool" == "html2text" ]]; then
        measure_time_ms "html2text < \"$htmlfile\" > /dev/null"
    elif [[ "$tool" == "lynx" ]]; then
        measure_time_ms "LANG=ko_KR.UTF-8 lynx -assume_charset=utf-8 -display_charset=utf-8 -dump -nolist -width=1000 \"$htmlfile\" > /dev/null"
    else
        echo "Unknown tool: $tool" >&2
        return 1
    fi
}

profile_parse_tool() {
    local tool="$1"
    local htmlfile="$2"
    local selector="$3"

    if [[ "$tool" == "pup" ]]; then
        measure_time_ms "pup \"$selector\" -f \"$htmlfile\" > /dev/null"
    elif [[ "$tool" == "htmlq" ]]; then
        measure_time_ms "htmlq \"$selector\" -f \"$htmlfile\" > /dev/null"
    else
        echo "Unknown tool: $tool" >&2
        return 1
    fi
}

summarize_times() {
    local label="$1"
    shift
    local times=("$@")

    printf "\n[%s STATS]\n" "$label"
    printf "Count: %d\n" "${#times[@]}"

    local sorted_times
    sorted_times=$(printf '%s\n' "${times[@]}" | sort -n)
    local count=${#times[@]}

    # min, max
    local min=$(echo "$sorted_times" | head -n1)
    local max=$(echo "$sorted_times" | tail -n1)

    # mean
    local sum=0
    for t in "${times[@]}"; do
        sum=$((sum + t))
    done
    local mean=$((sum / count))

    # helper: percentile index with rounding up
    percentile_idx() {
        local pct=$1
        echo $(( (count * pct + 99) / 100 ))
    }

    local p25_idx=$(percentile_idx 25)
    local p50_idx=$(percentile_idx 50)
    local p75_idx=$(percentile_idx 75)
    local p95_idx=$(percentile_idx 95)
    local p99_idx=$(percentile_idx 99)

    local q1=$(echo "$sorted_times" | sed -n "${p25_idx}p")
    local median=$(echo "$sorted_times" | sed -n "${p50_idx}p")
    local q3=$(echo "$sorted_times" | sed -n "${p75_idx}p")
    local p95=$(echo "$sorted_times" | sed -n "${p95_idx}p")
    local p99=$(echo "$sorted_times" | sed -n "${p99_idx}p")

    echo "Min:    $min ms"
    echo "Q1:     $q1 ms"
    echo "Median: $median ms"
    echo "Q3:     $q3 ms"
    echo "P95:    $p95 ms"
    echo "P99:    $p99 ms"
    echo "Max:    $max ms"
    echo "Mean:   $mean ms"
    echo "Total:  $sum ms"
}

profile_convert_html() {
    local tool="$1"
    local -a results=()

    echo ""
    echo "[$tool]"
    while IFS= read -r f; do
        local fullpath="$target_dir/$f"
        # echo "$f"
        local t
        t=$(profile_convert_tool "$tool" "$fullpath")
        results+=("$t")
    done < <(find "$target_dir" -type f -name "*.html" -printf "%f\n" | sort -n)

    summarize_times "$tool" "${results[@]}"
}

profile_parse_html() {
    
    local tool="$1"
    local -a results=()

    echo ""
    echo "[$tool]"
    while IFS= read -r f; do
        local fullpath="$target_dir/$f"
        # echo "$f"
        local t
        t=$(profile_parse_tool "$tool" "$fullpath" "$selector")
        results+=("$t")
    done < <(find "$target_dir" -type f -name "*.html" -printf "%f\n" | sort -n)

    summarize_times "$tool" "${results[@]}"
}

# Run convert html
profile_convert_html "pandoc"
profile_convert_html "html2text"
profile_convert_html "lynx"

# Run parse html
profile_parse_html "htmlq"
profile_parse_html "pup"
#!/usr/bin/env bash
# descendant - 지정한 CSS selector의 직계 자손 태그 이름 출력

usage() {
  echo "Usage: descendant <CSS_SELECTOR> [-f FILE]" >&2
  exit 1
}

# 인자 파싱
selector=""
file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f)
      shift
      file="$1"
      ;;
    -*)
      usage
      ;;
    *)
      if [[ -z "$selector" ]]; then
        selector="$1"
      else
        usage
      fi
      ;;
  esac
  shift
done

if [[ -z "$selector" ]]; then
  usage
fi

# pup 실행
if [[ -n "$file" ]]; then
  pup_out=$(pup "$selector json{}" -f "$file")
else
  pup_out=$(pup "$selector json{}")
fi

# jq 처리 (직계 자식 태그 출력)
echo "$pup_out" | jq -r '.[0].children // [] | .[] | .tag'
#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: ./split_dir [{-d|--directory} DIR] [{-p|--prefix} PREFIX] [{-l|--line} LINE] [--dest DEST]" >&2
  exit 1
}

basedir=$(dirname "$(realpath "$0")")

directory=""
prefix=""
dest=""
line="1024"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--directory)
      shift; directory="$1"
      ;;
    -l|--line)
      shift; line="$1"
      ;;
    -p|--prefix)
      shift; prefix="$1"
      ;;
    --dest)
      shift; dest="$1"
      ;;
    -*)
      usage
      ;;
    *)
      usage
      ;;
  esac
  shift
done

if [[ -z "$directory" ]]; then
  usage
fi

directory="$(realpath "$directory")"
prefix="${prefix:-$(basename "$directory")}"
dest="$(realpath "${dest:-.}")"

printf "directory: %s, prefix: %s, dest: %s, line: %s\n" "$directory" "$prefix" "$dest" "$line"

cd "$dest"

# 파일 리스트 만들고 split
find "$directory" -maxdepth 1 -type f -printf "%f\n" | sort -n | split -dl "$line" - "${prefix}_"

find "$dest" -name "${prefix}_*" | grep -v ".tgz$" | while read f; do
    base=$(basename "$f")
    tarfile="$dest/${base}.tgz"
    tar --directory="$directory" --files-from="$f" -czf "$tarfile"

    split_dir="$dest/dir_${base}"
    mkdir -p "$split_dir"
    tar --directory "$split_dir" -xzf "$tarfile"
done

find "$dest" -name "${prefix}_*" | grep -v ".tgz$" | xargs -I@ rm @
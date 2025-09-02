#!/bin/bash
set -euo pipefail

echo "Generating curl shell..."
if [[ -z "${DATA_DIR:-}" ]]; then
    echo "Error: DATA_DIR environment variable is not set"
    exit 1
fi

if [[ -z "${TOPICS_CSV:-}" ]]; then
    echo "Error: TOPICS_CSV environment variable is not set"
    exit 1
fi

if [[ -z "${GENERATED_SHELL_DIR:-}" ]]; then
    echo "Error: GENERATED_SHELL_DIR environment variable is not set"
    exit 1
fi

awk -v html_dir="${HTML_DIR}" -f ${BASE_DIR}/code_generator/4_generate_curl.awk "${TOPICS_CSV}" > ${GENERATED_SHELL_DIR}/4_fetch_html.sh

echo "Curl shell generated successfully to ${GENERATED_SHELL_DIR}/4_fetch_html.sh"

echo "Executing curl shell..."
bash ${GENERATED_SHELL_DIR}/4_fetch_html.sh
echo "Executing curl shell done"
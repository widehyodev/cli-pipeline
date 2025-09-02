#!/bin/bash
echo "Cleaning CSV..."

if [[ -z "${DATA_DIR:-}" ]]; then
    echo "Error: DATA_DIR environment variable is not set"
    exit 1
fi

if [[ -z "${RESULT_DIR:-}" ]]; then
    echo "Error: RESULT_DIR environment variable is not set"
    exit 1
fi

seq_csv_file="${RESULT_DIR}/seq_lynx_out.csv"
echo "Cleaning ${seq_csv_file}..."
csvclean -a --omit-error-rows ${seq_csv_file} 1>${RESULT_DIR}/seq_lynx_out_clean.csv 2>${RESULT_DIR}/seq_lynx_out_error.csv
echo "original rows: "
wc ${seq_csv_file}
echo "cleaned rows: "
csvstat --count ${RESULT_DIR}/seq_lynx_out_clean.csv
echo "error csv rows: "
wc ${RESULT_DIR}/seq_lynx_out_error.csv

xargs_csv_file="${RESULT_DIR}/xargs_lynx_out.csv"
echo "Cleaning ${xargs_csv_file}..."
csvclean -a --omit-error-rows ${xargs_csv_file} 1>${RESULT_DIR}/xargs_lynx_out_clean.csv 2>${RESULT_DIR}/xargs_lynx_out_error.csv
echo "original rows: "
wc ${xargs_csv_file}
echo "cleaned rows: "
csvstat --count ${RESULT_DIR}/xargs_lynx_out_clean.csv
echo "error csv rows: "
wc ${RESULT_DIR}/xargs_lynx_out_error.csv
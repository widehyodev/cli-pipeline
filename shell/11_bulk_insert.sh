#!/bin/bash
set -euo pipefail

echo "Bulk inserting into database..."

if [[ -z "${RESULT_DIR:-}" ]]; then
    echo "Error: RESULT_DIR environment variable is not set"
    exit 1
fi

if [[ -z "${POSTGRES_HOST:-}" ]]; then
    echo "Error: POSTGRES_HOST environment variable is not set"
    exit 1
fi

if [[ -z "${POSTGRES_PORT:-}" ]]; then
    echo "Error: POSTGRES_PORT environment variable is not set"
    exit 1
fi

if [[ -z "${POSTGRES_USER:-}" ]]; then 
    echo "Error: POSTGRES_USER environment variable is not set"
    exit 1
fi

if [[ -z "${POSTGRES_DB:-}" ]]; then
    echo "Error: POSTGRES_DB environment variable is not set"
    exit 1
fi

bulk_insert_csv="${RESULT_DIR}/xargs_lynx_out_clean.csv"
echo "bulk inserting ${bulk_insert_csv} into database"
record_count=$(csvstat --count --no-header-row ${bulk_insert_csv})
echo "record count: ${record_count}"
psql -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\COPY geeknews_topic(id, url, title, content) FROM ${bulk_insert_csv} WITH (FORMAT csv);"

echo "Bulk inserting into database done"
#!/bin/bash
set -euo pipefail

echo "Initializing database..."

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

if [[ -z "${INIT_SQL_FILE:-}" ]]; then
    echo "Error: INIT_SQL_FILE environment variable is not set"
    exit 1
fi

psql -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f ${INIT_SQL_FILE}

echo "Database initialized successfully"
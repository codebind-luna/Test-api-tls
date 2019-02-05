#!/bin/bash
set -ex

PORT=${PORT:-9000}
UWSGI_TIMEOUT=${UWSGI_TIMEOUT:-300}

TEST_THREADS=${PROMENADE_THREADS:-1}
TEST_WORKERS=${PROMENADE_WORKERS:-4}

# TLS certificate and key
#TEST_CERT_FILE=${TEST_CERT_FILE:-"tls.crt"}
#TEST_KEY_FILE=${TEST_KEY_FILE:-"tls.key"}

if [ "$1" = 'server' ]; then
    if [ -f "${TEST_CERT_FILE}" ]; then
        # This also disables SSLv3, TLS1.0 and TLS1.1. TODO: make configurable
        HTTP_PORT_STRING="--https :${PORT},${TEST_CERT_FILE},${TEST_KEY_FILE} --ssl-option 369098752"
    else
        HTTP_PORT_STRING="--http :${PORT}"
    fi
fi

if [ "$1" = 'server' ]; then
    exec uwsgi \
        ${HTTP_PORT_STRING} \
        --http-timeout "${UWSGI_TIMEOUT}" \
        --harakiri "${UWSGI_TIMEOUT}" \
        --socket-timeout "${UWSGI_TIMEOUT}" \
        --harakiri-verbose \
        -b 32768 \
        --lazy-apps \
        --master \
        --thunder-lock \
        --die-on-term \
        -z "${UWSGI_TIMEOUT}" \
        --wsgi-file ./app/main.py \
        --callable app \
        --enable-threads \
        --threads "${TEST_THREADS}" \
        --workers "${TEST_WORKERS}"
fi


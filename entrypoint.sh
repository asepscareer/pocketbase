#!/bin/sh
set -e
: "${PORT:=8080}"
: "${DATA_DIR:=/data}"
mkdir -p "$DATA_DIR"
chown -R pocketbase:pocketbase "$DATA_DIR"
exec su-exec pocketbase /usr/local/bin/pocketbase serve --http=0.0.0.0:${PORT} --dir="${DATA_DIR}"

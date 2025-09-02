#!/bin/sh
set -e


: "${PORT:=8080}"
DATA_DIR="${DATA_DIR:-/srv/pb}"
exec /usr/local/bin/pocketbase serve --http=0.0.0.0:${PORT} --dir="${DATA_DIR}"
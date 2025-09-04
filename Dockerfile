FROM alpine:3.20 AS downloader
ARG PB_VERSION=0.29.3
ARG PB_SHA256=""
RUN apk add --no-cache curl unzip ca-certificates && update-ca-certificates
WORKDIR /tmp/pb
RUN curl -fsSL -o pocketbase.zip "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip"
RUN if [ -n "$PB_SHA256" ]; then echo "${PB_SHA256} pocketbase.zip" | sha256sum -c - ; else echo "WARNING: PB_SHA256 not set, skipping checksum verification"; fi
RUN unzip pocketbase.zip && chmod +x pocketbase && ./pocketbase --help >/dev/null 2>&1 || true

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tini wget su-exec && update-ca-certificates
RUN addgroup -S pocketbase && adduser -S -G pocketbase -u 65532 pocketbase
WORKDIR /app
COPY --from=downloader /tmp/pb/pocketbase /usr/local/bin/pocketbase
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
COPY ./pb_migrations ./pb_migrations
COPY ./pb_hooks ./pb_hooks
ENV PORT=8080
ENV DATA_DIR=/data
EXPOSE 8080
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]

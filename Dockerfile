# ---------- Stage 1: Download ----------
FROM alpine:3.20 AS downloader


ARG PB_VERSION=0.29.3
# (Optional) SHA256 of the downloaded zip from the GitHub release page
ARG PB_SHA256=""


RUN apk add --no-cache curl unzip ca-certificates && update-ca-certificates
WORKDIR /tmp/pb


# Download PocketBase release (linux_amd64)
RUN curl -fsSL -o pocketbase.zip \
"https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip"


# Verify checksum if provided
RUN if [ -n "$PB_SHA256" ]; then \
echo "${PB_SHA256} pocketbase.zip" | sha256sum -c - ; \
else \
echo "WARNING: PB_SHA256 not set, skipping checksum verification"; \
fi


# Extract & make executable
RUN unzip pocketbase.zip \
&& chmod +x pocketbase \
&& ./pocketbase --help >/dev/null 2>&1 || true


# ---------- Stage 2: Runtime ----------
FROM alpine:3.20


# tini for proper signal handling (PID 1)
RUN apk add --no-cache ca-certificates tini wget && update-ca-certificates


# Non-root user
RUN addgroup -S pocketbase && adduser -S -G pocketbase -u 65532 pocketbase


# Workdir & data path
WORKDIR /srv/pb
RUN mkdir -p /srv/pb/pb_data \
&& chown -R pocketbase:pocketbase /srv/pb


# Copy binary and entrypoint
COPY --from=downloader /tmp/pb/pocketbase /usr/local/bin/pocketbase
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
&& chown pocketbase:pocketbase /usr/local/bin/entrypoint.sh


# Copy migrations/hooks (kept even if empty; folders include a .keep file)
COPY ./pb_migrations ./pb_migrations
COPY ./pb_hooks ./pb_hooks
RUN chown -R pocketbase:pocketbase /srv/pb


# Run as non-root
USER 65532


# Default ENV; Railway will inject PORT at runtime
ENV PORT=8080
ENV DATA_DIR=/srv/pb


# Expose (informational)
EXPOSE 8080


# Healthcheck (HTTP 200 on root)
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
CMD wget -q --spider "http://127.0.0.1:${PORT}/" || exit 1


# OCI Metadata
LABEL org.opencontainers.image.title="PocketBase on Alpine (Railway)" \
org.opencontainers.image.description="Production-ready PocketBase image for Railway: pinned version, non-root, healthcheck, tiny runtime" \
org.opencontainers.image.version="${PB_VERSION}" \
org.opencontainers.image.source="https://github.com/pocketbase/pocketbase" \
org.opencontainers.image.licenses="MIT"



# Use tini, then our entrypoint (binds to $PORT)
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
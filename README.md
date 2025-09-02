# PocketBase

Deploy a production‑ready PocketBase on Railway: pinned version, non‑root runtime, healthcheck, and volume hint for persistence.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/pocketbase-1?referralCode=asepsp&utm_medium=integration&utm_source=template&utm_campaign=generic)


## Features
- Reproducible builds via `PB_VERSION` (+ optional SHA256 verify)
- Small runtime image (multi‑stage Alpine)
- Healthcheck & `$PORT`‑aware entrypoint
- Volume hint at `/srv/pb/pb_data`
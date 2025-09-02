# PocketBase on Railway (Template)


Deploy a production‑ready PocketBase on Railway: pinned version, non‑root runtime, healthcheck, and volume hint for persistence.


[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy)


## Features
- Reproducible builds via `PB_VERSION` (+ optional SHA256 verify)
- Small runtime image (multi‑stage Alpine)
- Non‑root user & proper signal handling via `tini`
- Healthcheck & `$PORT`‑aware entrypoint
- Volume hint at `/srv/pb/pb_data`


## Quick Start
1. **Use this template** → create your GitHub repo.
2. Click **Deploy on Railway** and select your repo.
3. In Railway, create a **Volume** and mount it to `/srv/pb/pb_data`.
4. (Optional) Set build args in service build settings:
- `PB_VERSION=0.29.3`
- `PB_SHA256=<sha256 from GitHub release>`
5. Deploy. Railway injects `PORT` automatically.
6. **When you need schema or hooks**: just add files into `pb_migrations/` or `pb_hooks/` and push—**no Dockerfile changes** required.

## Project Layout
```
.
├─ Dockerfile             # multi-stage build for PocketBase
├─ entrypoint.sh          # starts pocketbase with $PORT and $DATA_DIR
├─ railway.json           # Railway deployment config
├─ .dockerignore
├─ .env.example
├─ pb_migrations/         # put PocketBase migration files here (included in build)
│  └─ .keep
└─ pb_hooks/              # put PocketBase hook scripts here 
  └─ .keep
```
#!/bin/sh
set -e

echo "Menjalankan migrasi database..."
alembic upgrade head

if [ "$APP_ENV" = "production" ]; then
  echo "Menjalankan API (produksi, ${API_WORKERS:-2} worker)..."
  # --proxy-headers: percayai X-Forwarded-* dari Nginx.
  # --root-path /api: API diakses lewat Nginx di bawah awalan /api.
  exec uvicorn app.main:app --host 0.0.0.0 --port 8000 \
    --workers "${API_WORKERS:-2}" --proxy-headers --forwarded-allow-ips="*" \
    --root-path /api
fi

echo "Menjalankan API (pengembangan, auto-reload)..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

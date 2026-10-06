#!/bin/sh
set -e

echo "Menjalankan migrasi database..."
alembic upgrade head

echo "Menjalankan API..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /code

# INSTALL_DEV=false untuk image produksi (tanpa pytest).
ARG INSTALL_DEV=true

# Pasang dependensi lebih dulu agar layer ini di-cache selama
# requirements*.txt tidak berubah.
COPY requirements.txt requirements-dev.txt ./
RUN if [ "$INSTALL_DEV" = "true" ]; then \
      pip install --no-cache-dir -r requirements-dev.txt; \
    else \
      pip install --no-cache-dir -r requirements.txt; \
    fi

COPY . .

# User biasa (bukan root) untuk produksi; dipilih lewat `user: app` di
# docker-compose.prod.yml. Mode pengembangan tetap root agar volume lama
# dan folder yang di-bind-mount dapat ditulis.
RUN useradd --create-home --uid 1000 app \
    && mkdir -p /data/uploads && chown app:app /data/uploads

EXPOSE 8000
# start.sh menjalankan migrasi Alembic lalu uvicorn.
CMD ["sh", "start.sh"]

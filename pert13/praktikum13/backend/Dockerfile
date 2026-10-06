FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /code

# Pasang dependensi lebih dulu agar layer ini di-cache selama
# requirements*.txt tidak berubah. requirements-dev.txt berisi pytest.
COPY requirements.txt requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements-dev.txt

COPY . .

EXPOSE 8000
# start.sh menjalankan migrasi Alembic lalu uvicorn.
CMD ["sh", "start.sh"]

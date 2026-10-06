#!/bin/sh
set -e

# Folder vendor berasal dari image; pasang ulang bila kosong.
if [ ! -f vendor/autoload.php ]; then
  composer install --no-interaction --prefer-dist
fi

# Konfigurasi datang dari environment docker-compose; berkas .env kosong
# cukup agar Laravel tidak memberi peringatan saat membacanya.
[ -f .env ] || touch .env

# Folder storage harus bisa ditulis (log, cache view, sesi).
mkdir -p storage/framework/cache storage/framework/sessions \
         storage/framework/views storage/logs bootstrap/cache

echo "Menunggu tabel milik FastAPI (Alembic)..."
until php artisan db:table kategori >/dev/null 2>&1; do sleep 2; done

php artisan migrate --force   # hanya tabel milik Laravel (admins, sessions, cache, jobs)
php artisan db:seed --force   # akun admin pertama
php artisan filament:upgrade  # salin aset CSS/JS Filament ke public/

if [ "$APP_ENV" = "production" ]; then
  # Cache konfigurasi, rute, view, dan komponen Filament agar lebih cepat.
  php artisan optimize
  php artisan filament:optimize
fi

exec frankenphp php-server --root public/ --listen :8080

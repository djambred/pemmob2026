#!/bin/sh
# Memulihkan database dan foto bukti dari folder backups/.
# Pemakaian:  sh scripts/restore.sh WAKTU [berkas-compose]
#   contoh:   sh scripts/restore.sh 20261006-180000
# PERINGATAN: isi database saat ini akan DITIMPA.
set -e
WAKTU=${1:?Sebutkan WAKTU cadangan, misalnya 20261006-180000}
COMPOSE="docker compose -f ${2:-docker-compose.yml}"

gunzip -c "backups/db-$WAKTU.sql.gz" | $COMPOSE exec -T mysql sh -c \
  'exec mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'

if [ -f "backups/uploads-$WAKTU.tar.gz" ]; then
  $COMPOSE exec -T api tar -C /data -xzf - < "backups/uploads-$WAKTU.tar.gz"
fi
echo "Pemulihan dari $WAKTU selesai."

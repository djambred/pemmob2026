<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;

/** Pengumuman untuk pengguna aplikasi (tabel dibuat Alembic). */
#[Table('pengumuman')]
#[Fillable(['judul', 'isi', 'aktif', 'mulai', 'sampai'])]
class Pengumuman extends Model
{
    protected function casts(): array
    {
        return [
            'aktif' => 'boolean',
            'mulai' => 'date',
            'sampai' => 'date',
        ];
    }

    /** Status untuk ditampilkan di tabel admin. */
    public function status(): string
    {
        return match (true) {
            ! $this->aktif => 'Nonaktif',
            $this->mulai?->isFuture() ?? false => 'Terjadwal',
            $this->sampai?->endOfDay()->isPast() ?? false => 'Berakhir',
            default => 'Tayang',
        };
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Kegiatan milik pengguna mobile (tabel dibuat Alembic). */
#[Table('kegiatan')]
class Kegiatan extends Model
{
    protected function casts(): array
    {
        return [
            'tanggal' => 'date',
            'selesai' => 'boolean',
            'nominal' => 'integer',
        ];
    }

    public function pengguna(): BelongsTo
    {
        return $this->belongsTo(Pengguna::class, 'user_id');
    }

    public function kategori(): BelongsTo
    {
        return $this->belongsTo(Kategori::class);
    }
}

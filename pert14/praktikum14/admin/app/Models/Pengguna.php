<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Pengguna aplikasi mobile. Tabel `users` dibuat dan dimigrasi oleh
 * Alembic (FastAPI), jadi TIDAK ada migrasi Laravel untuk tabel ini.
 */
#[Table('users')]
#[Fillable(['nama', 'target_harian', 'aktif'])]
#[Hidden(['password_hash'])]
class Pengguna extends Model
{
    // Tabel users hanya punya created_at (tanpa updated_at).
    const UPDATED_AT = null;

    protected function casts(): array
    {
        return [
            'aktif' => 'boolean',
            'target_harian' => 'integer',
        ];
    }

    public function kegiatan(): HasMany
    {
        return $this->hasMany(Kegiatan::class, 'user_id');
    }
}

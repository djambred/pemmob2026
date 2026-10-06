<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Foundation\Auth\User as Authenticatable;

/**
 * Akun login dashboard Filament (tabel `admins`, dibuat migrasi Laravel).
 * Berbeda dengan Pengguna (tabel `users`) yang login dari aplikasi mobile.
 */
#[Fillable(['name', 'email', 'password'])]
#[Hidden(['password', 'remember_token'])]
class Admin extends Authenticatable implements FilamentUser
{
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /** Wajib di APP_ENV=production: siapa yang boleh membuka panel. */
    public function canAccessPanel(Panel $panel): bool
    {
        return true;
    }
}

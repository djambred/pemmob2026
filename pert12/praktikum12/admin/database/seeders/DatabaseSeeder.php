<?php

namespace Database\Seeders;

use App\Models\Admin;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Membuat akun admin pertama dari environment (ADMIN_EMAIL, ADMIN_PASSWORD).
     * Aman dijalankan berulang: akun yang sudah ada tidak diubah.
     */
    public function run(): void
    {
        Admin::firstOrCreate(
            ['email' => env('ADMIN_EMAIL', 'admin@tabungku.test')],
            [
                'name' => 'Administrator',
                'password' => env('ADMIN_PASSWORD', 'admin12345'),
            ],
        );
    }
}

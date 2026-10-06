<?php

namespace App\Filament\Resources\Penggunas\Pages;

use App\Filament\Resources\Penggunas\PenggunaResource;
use Filament\Resources\Pages\ManageRecords;

class ManagePenggunas extends ManageRecords
{
    protected static string $resource = PenggunaResource::class;

    // Tanpa tombol "Buat": data berasal dari aplikasi mobile.
}

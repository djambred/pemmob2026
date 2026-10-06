<?php

namespace App\Filament\Resources\Kegiatans\Pages;

use App\Filament\Resources\Kegiatans\KegiatanResource;
use Filament\Resources\Pages\ManageRecords;

class ManageKegiatans extends ManageRecords
{
    protected static string $resource = KegiatanResource::class;

    // Tanpa tombol "Buat": data berasal dari aplikasi mobile.
}

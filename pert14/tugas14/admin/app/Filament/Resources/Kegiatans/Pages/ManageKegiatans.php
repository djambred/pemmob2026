<?php

namespace App\Filament\Resources\Kegiatans\Pages;

use App\Filament\Resources\Kegiatans\KegiatanResource;
use App\Models\Kegiatan;
use Filament\Actions\Action;
use Filament\Resources\Pages\ManageRecords;
use Filament\Support\Icons\Heroicon;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ManageKegiatans extends ManageRecords
{
    protected static string $resource = KegiatanResource::class;

    // Tanpa tombol "Buat": data berasal dari aplikasi mobile.
    protected function getHeaderActions(): array
    {
        return [
            Action::make('ekspor')
                ->label('Ekspor CSV')
                ->icon(Heroicon::OutlinedArrowDownTray)
                ->action(fn (): StreamedResponse => $this->eksporCsv()),
        ];
    }

    /** Mengekspor baris sesuai filter dan pencarian tabel yang sedang aktif. */
    private function eksporCsv(): StreamedResponse
    {
        $query = $this->getFilteredSortedTableQuery()->with(['pengguna', 'kategori']);

        return response()->streamDownload(function () use ($query): void {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['tanggal', 'pengguna', 'judul', 'tipe', 'kategori', 'nominal', 'selesai']);
            // lazy(): baris diambil bertahap agar memori tetap kecil.
            $query->lazy()->each(function (Kegiatan $k) use ($out): void {
                fputcsv($out, [
                    $k->tanggal->toDateString(),
                    $k->pengguna?->nama,
                    $k->judul,
                    $k->tipe,
                    $k->kategori?->nama ?? '-',
                    $k->nominal,
                    $k->selesai ? 1 : 0,
                ]);
            });
            fclose($out);
        }, 'kegiatan-'.now()->format('Ymd-His').'.csv', ['Content-Type' => 'text/csv']);
    }
}

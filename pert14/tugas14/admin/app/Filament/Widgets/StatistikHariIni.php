<?php

namespace App\Filament\Widgets;

use App\Models\Kegiatan;
use App\Models\Pengguna;
use Filament\Support\Icons\Heroicon;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Number;

/** Kartu angka ringkas di bagian atas dashboard. */
class StatistikHariIni extends StatsOverviewWidget
{
    protected static ?int $sort = 1;

    protected ?string $heading = 'Hari ini';

    protected function getStats(): array
    {
        $hariIni = Kegiatan::whereDate('tanggal', today());
        $masuk = (clone $hariIni)->where('tipe', 'pemasukan')->sum('nominal');
        $keluar = (clone $hariIni)->where('tipe', 'pengeluaran')->sum('nominal');

        return [
            Stat::make('Pengguna aktif', Pengguna::where('aktif', true)->count())
                ->description(Pengguna::whereDate('created_at', today())->count().' daftar hari ini')
                ->descriptionIcon(Heroicon::OutlinedUserPlus),
            Stat::make('Kegiatan dicatat', (clone $hariIni)->count())
                ->description((clone $hariIni)->where('selesai', true)->count().' selesai')
                ->chart($this->jumlahKegiatanTujuhHari())
                ->color('primary'),
            Stat::make('Pemasukan', $this->rupiah($masuk))
                ->descriptionIcon(Heroicon::OutlinedArrowTrendingUp)
                ->description('Semua pengguna')
                ->color('success'),
            Stat::make('Pengeluaran', $this->rupiah($keluar))
                ->descriptionIcon(Heroicon::OutlinedArrowTrendingDown)
                ->description('Semua pengguna')
                ->color('danger'),
        ];
    }

    /** Data grafik kecil (sparkline): jumlah kegiatan 7 hari terakhir. */
    private function jumlahKegiatanTujuhHari(): array
    {
        $perTanggal = Kegiatan::query()
            ->whereDate('tanggal', '>=', today()->subDays(6))
            ->whereDate('tanggal', '<=', today())
            ->selectRaw('tanggal, COUNT(*) AS jumlah')
            ->groupBy('tanggal')
            ->pluck('jumlah', 'tanggal');

        return collect(range(6, 0))
            ->map(fn (int $mundur) => (int) ($perTanggal[today()->subDays($mundur)->toDateString()] ?? 0))
            ->all();
    }

    private function rupiah(int|float $nilai): string
    {
        return Number::currency($nilai, in: 'IDR', locale: 'id', precision: 0);
    }
}

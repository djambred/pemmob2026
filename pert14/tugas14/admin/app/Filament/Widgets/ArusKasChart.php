<?php

namespace App\Filament\Widgets;

use App\Models\Kegiatan;
use Filament\Widgets\ChartWidget;

/** Grafik garis pemasukan vs pengeluaran harian (semua pengguna). */
class ArusKasChart extends ChartWidget
{
    protected static ?int $sort = 3;

    protected ?string $heading = 'Arus kas 14 hari terakhir';

    protected ?string $maxHeight = '280px';

    protected function getData(): array
    {
        $mulai = today()->subDays(13);
        $perTanggal = Kegiatan::query()
            ->whereDate('tanggal', '>=', $mulai)
            ->groupBy('tanggal')
            ->selectRaw("tanggal,
                SUM(CASE WHEN tipe = 'pemasukan' THEN nominal ELSE 0 END) AS masuk,
                SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal ELSE 0 END) AS keluar")
            ->get()
            ->keyBy(fn (Kegiatan $k) => $k->tanggal->toDateString());

        // Tanggal tanpa kegiatan tetap tampil dengan nilai 0.
        $hari = collect(range(0, 13))->map(fn (int $i) => $mulai->copy()->addDays($i));

        return [
            'datasets' => [
                [
                    'label' => 'Pemasukan',
                    'data' => $hari->map(fn ($d) => (int) ($perTanggal[$d->toDateString()]->masuk ?? 0))->all(),
                    'borderColor' => '#22c55e',
                    'backgroundColor' => '#22c55e',
                ],
                [
                    'label' => 'Pengeluaran',
                    'data' => $hari->map(fn ($d) => (int) ($perTanggal[$d->toDateString()]->keluar ?? 0))->all(),
                    'borderColor' => '#ef4444',
                    'backgroundColor' => '#ef4444',
                ],
            ],
            'labels' => $hari->map(fn ($d) => $d->format('d/m'))->all(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}

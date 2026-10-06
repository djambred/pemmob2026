<?php

namespace Tests\Feature;

use App\Filament\Resources\Kategoris\Pages\ManageKategoris;
use App\Filament\Resources\Kegiatans\Pages\ManageKegiatans;
use App\Filament\Resources\Penggunas\Pages\ManagePenggunas;
use App\Filament\Resources\Pengumumen\Pages\ManagePengumumen;
use App\Filament\Widgets\ArusKasChart;
use App\Filament\Widgets\PengeluaranPerKategoriChart;
use App\Filament\Widgets\StatistikHariIni;
use App\Models\Admin;
use App\Models\Kategori;
use App\Models\Kegiatan;
use App\Models\Pengguna;
use App\Models\Pengumuman;
use Livewire\Livewire;
use Tests\TestCase;

/**
 * Uji asap (smoke test) dashboard terhadap database docker compose.
 * Tidak memakai RefreshDatabase karena tabel dibuat oleh Alembic.
 * Jalankan: docker compose exec admin php artisan test
 */
class DashboardTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        $this->actingAs(Admin::firstOrFail());
    }

    public function test_tamu_diarahkan_ke_login(): void
    {
        auth()->logout();
        $this->get('/admin')->assertRedirect('/admin/login');
    }

    public function test_halaman_dashboard_dan_resource_terbuka(): void
    {
        foreach (['/admin', '/admin/kegiatans', '/admin/penggunas', '/admin/kategoris', '/admin/pengumuman'] as $url) {
            $this->get($url)->assertOk();
        }
    }

    public function test_model_membaca_tabel_milik_fastapi(): void
    {
        $this->assertGreaterThanOrEqual(5, Kategori::count());
        $kegiatan = Kegiatan::with(['pengguna', 'kategori'])->first();
        if ($kegiatan) {
            $this->assertInstanceOf(Pengguna::class, $kegiatan->pengguna);
        }
    }

    public function test_tabel_menampilkan_data(): void
    {
        Livewire::test(ManageKategoris::class)
            ->assertCanSeeTableRecords(Kategori::orderBy('urutan')->get());

        Livewire::test(ManagePenggunas::class)
            ->assertCanSeeTableRecords(Pengguna::latest()->limit(10)->get());

        Livewire::test(ManageKegiatans::class)
            ->assertCanSeeTableRecords(Kegiatan::orderByDesc('tanggal')->limit(10)->get());
    }

    public function test_widget_dashboard_tampil(): void
    {
        Livewire::test(StatistikHariIni::class)
            ->assertSee('Pengguna aktif')
            ->assertSee('Pengeluaran');

        Livewire::test(PengeluaranPerKategoriChart::class)
            ->assertSee('Pengeluaran per kategori')
            ->set('filter', '7')
            ->assertOk();

        Livewire::test(ArusKasChart::class)->assertSee('Arus kas');
    }

    public function test_filter_kegiatan(): void
    {
        $semua = Kegiatan::all();
        $pengeluaran = $semua->where('tipe', 'pengeluaran');
        $lainnya = $semua->where('tipe', '!=', 'pengeluaran');

        Livewire::test(ManageKegiatans::class)
            ->filterTable('tipe', 'pengeluaran')
            ->assertCanSeeTableRecords($pengeluaran)
            ->assertCanNotSeeTableRecords($lainnya);

        Livewire::test(ManageKegiatans::class)
            ->filterTable('rentang_tanggal', ['dari' => '2100-01-01', 'sampai' => null])
            ->assertCountTableRecords(0);
    }

    public function test_foto_bukti_memakai_url_api(): void
    {
        $kegiatan = Kegiatan::whereNotNull('bukti')->first();
        if (! $kegiatan) {
            $this->markTestSkipped('Belum ada kegiatan dengan bukti.');
        }

        $this->assertSame('http://localhost:8000/'.$kegiatan->bukti, $kegiatan->buktiUrl());
        Livewire::test(ManageKegiatans::class)->assertSee($kegiatan->buktiUrl());
    }

    public function test_ekspor_csv_mengikuti_filter(): void
    {
        Livewire::test(ManageKegiatans::class)
            ->filterTable('tipe', 'pengeluaran')
            ->callAction('ekspor')
            ->assertFileDownloaded();
    }

    public function test_status_pengumuman(): void
    {
        $this->assertSame('Tayang', (new Pengumuman(['aktif' => true]))->status());
        $this->assertSame('Nonaktif', (new Pengumuman(['aktif' => false]))->status());
        $this->assertSame('Terjadwal', (new Pengumuman(['aktif' => true, 'mulai' => now()->addDay()]))->status());
        $this->assertSame('Berakhir', (new Pengumuman(['aktif' => true, 'sampai' => now()->subDay()]))->status());

        Livewire::test(ManagePengumumen::class)->assertOk();
    }
}

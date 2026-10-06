<?php

namespace App\Filament\Resources\Kategoris;

use App\Filament\Resources\Kategoris\Pages\ManageKategoris;
use App\Models\Kategori;
use BackedEnum;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;

/**
 * Kategori pengeluaran. Perubahan di sini langsung terlihat di aplikasi
 * mobile karena Flutter membaca GET /kategori dari tabel yang sama.
 */
class KategoriResource extends Resource
{
    protected static ?string $model = Kategori::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedTag;

    protected static ?string $recordTitleAttribute = 'nama';

    protected static ?string $modelLabel = 'kategori';

    protected static ?string $pluralModelLabel = 'kategori';

    protected static ?int $navigationSort = 3;

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('nama')
                    ->required()
                    ->maxLength(30)
                    ->unique(ignoreRecord: true),
                TextInput::make('urutan')
                    ->numeric()
                    ->minValue(0)
                    ->default(0)
                    ->helperText('Urutan tampil di aplikasi (kecil di depan).'),
                Toggle::make('aktif')
                    ->default(true)
                    ->helperText('Kategori nonaktif tidak muncul di aplikasi.'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('urutan')
            // Baris dapat diurutkan dengan drag-and-drop; nilai disimpan ke kolom urutan.
            ->reorderable('urutan')
            ->columns([
                TextColumn::make('nama')
                    ->searchable(),
                TextColumn::make('urutan')
                    ->sortable(),
                ToggleColumn::make('aktif'),
                TextColumn::make('kegiatan_count')
                    ->counts('kegiatan')
                    ->label('Dipakai')
                    ->suffix(' kegiatan'),
                TextColumn::make('updated_at')
                    ->label('Diubah')
                    ->since()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->recordActions([
                EditAction::make(),
                // Kategori yang sudah dipakai tidak boleh dihapus (FK RESTRICT);
                // nonaktifkan saja.
                DeleteAction::make()
                    ->hidden(fn (Kategori $record): bool => $record->kegiatan()->exists()),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageKategoris::route('/'),
        ];
    }
}

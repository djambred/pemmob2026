<?php

namespace App\Filament\Resources\Penggunas;

use App\Filament\Resources\Penggunas\Pages\ManagePenggunas;
use App\Models\Pengguna;
use BackedEnum;
use Filament\Actions\EditAction;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

/**
 * Pengguna aplikasi mobile. Admin tidak membuat akun (pendaftaran lewat
 * aplikasi, password di-hash oleh FastAPI), tetapi dapat menonaktifkan akun.
 */
class PenggunaResource extends Resource
{
    protected static ?string $model = Pengguna::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static ?string $recordTitleAttribute = 'nama';

    protected static ?string $modelLabel = 'pengguna';

    protected static ?string $pluralModelLabel = 'pengguna';

    protected static ?int $navigationSort = 2;

    public static function canCreate(): bool
    {
        return false;
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('nama')
                    ->required()
                    ->maxLength(100),
                TextInput::make('email')
                    ->disabled()
                    ->dehydrated(false),
                TextInput::make('target_harian')
                    ->label('Target harian')
                    ->prefix('Rp')
                    ->numeric()
                    ->minValue(0)
                    ->required(),
                Toggle::make('aktif')
                    ->helperText('Akun nonaktif tidak dapat login dari aplikasi.'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('nama')
                    ->searchable(),
                TextColumn::make('email')
                    ->searchable(),
                TextColumn::make('target_harian')
                    ->label('Target')
                    ->money('IDR', locale: 'id', decimalPlaces: 0)
                    ->sortable(),
                TextColumn::make('kegiatan_count')
                    ->counts('kegiatan')
                    ->label('Kegiatan')
                    ->sortable(),
                ToggleColumn::make('aktif'),
                TextColumn::make('created_at')
                    ->label('Terdaftar')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->filters([
                TernaryFilter::make('aktif'),
            ])
            ->recordActions([
                EditAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManagePenggunas::route('/'),
        ];
    }
}

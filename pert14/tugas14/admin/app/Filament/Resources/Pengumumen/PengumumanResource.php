<?php

namespace App\Filament\Resources\Pengumumen;

use App\Filament\Resources\Pengumumen\Pages\ManagePengumumen;
use App\Models\Pengumuman;
use BackedEnum;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;

/**
 * Pengumuman yang tampil sebagai banner di halaman Hari Ini aplikasi
 * (GET /pengumuman). Contoh fitur proyek akhir end-to-end.
 */
class PengumumanResource extends Resource
{
    protected static ?string $model = Pengumuman::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedMegaphone;

    protected static ?string $recordTitleAttribute = 'judul';

    protected static ?string $modelLabel = 'pengumuman';

    protected static ?string $pluralModelLabel = 'pengumuman';

    // Generator memberi slug "pengumumen" (aturan jamak bahasa Inggris).
    protected static ?string $slug = 'pengumuman';

    protected static ?int $navigationSort = 4;

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('judul')
                    ->required()
                    ->maxLength(100)
                    ->columnSpanFull(),
                Textarea::make('isi')
                    ->required()
                    ->maxLength(500)
                    ->rows(4)
                    ->columnSpanFull(),
                DatePicker::make('mulai')
                    ->helperText('Kosongkan untuk tayang sekarang.'),
                DatePicker::make('sampai')
                    ->afterOrEqual('mulai')
                    ->helperText('Kosongkan untuk tanpa batas.'),
                Toggle::make('aktif')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('judul')
                    ->searchable()
                    ->description(fn (Pengumuman $record): string => str($record->isi)->limit(60)),
                TextColumn::make('status')
                    ->state(fn (Pengumuman $record): string => $record->status())
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Tayang' => 'success',
                        'Terjadwal' => 'info',
                        default => 'gray',
                    }),
                TextColumn::make('mulai')->date('d M Y')->placeholder('-'),
                TextColumn::make('sampai')->date('d M Y')->placeholder('-'),
                ToggleColumn::make('aktif'),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManagePengumumen::route('/'),
        ];
    }
}

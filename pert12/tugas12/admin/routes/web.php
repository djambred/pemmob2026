<?php

use Illuminate\Support\Facades\Route;

// Aplikasi ini hanya berisi dashboard Filament di /admin.
Route::redirect('/', '/admin');

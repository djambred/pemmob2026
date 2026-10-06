from datetime import datetime, timedelta, timezone

import jwt
from pwdlib import PasswordHash

from .config import settings

# Argon2: algoritma hash password yang direkomendasikan saat ini.
_hasher = PasswordHash.recommended()


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def cek_password(password: str, hash_tersimpan: str) -> bool:
    return _hasher.verify(password, hash_tersimpan)


def buat_access_token(user_id: int) -> str:
    sekarang = datetime.now(timezone.utc)
    payload = {
        "sub": str(user_id),  # subject: pemilik token
        "iat": sekarang,  # issued at
        "exp": sekarang + timedelta(minutes=settings.access_token_menit),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algoritma)


def baca_token(token: str) -> dict:
    """Melempar jwt.InvalidTokenError bila token rusak, palsu, atau kedaluwarsa."""
    return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algoritma])

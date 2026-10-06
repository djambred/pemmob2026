from typing import Annotated

import jwt
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select

from ..deps import DbSession, UserAktif
from ..models import User
from ..schemas import RefreshInput, Token, UserCreate, UserOut, UserUpdate
from ..security import (
    baca_token,
    buat_access_token,
    buat_refresh_token,
    cek_password,
    hash_password,
)

router = APIRouter(tags=["auth"])


@router.post("/auth/register", response_model=UserOut, status_code=status.HTTP_201_CREATED)
def register(data: UserCreate, db: DbSession):
    email = data.email.lower()
    if db.scalar(select(User).where(User.email == email)):
        raise HTTPException(status.HTTP_409_CONFLICT, "Email sudah terdaftar")
    user = User(nama=data.nama.strip(), email=email, password_hash=hash_password(data.password))
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.post("/auth/login", response_model=Token)
def login(form: Annotated[OAuth2PasswordRequestForm, Depends()], db: DbSession):
    """Login memakai form `username` (berisi email) dan `password`.

    Format form (bukan JSON) mengikuti standar OAuth2 sehingga tombol
    Authorize di Swagger UI dapat dipakai.
    """
    user = db.scalar(select(User).where(User.email == form.username.lower()))
    # Pesan sengaja sama untuk email salah maupun password salah.
    if user is None or not cek_password(form.password, user.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Email atau password salah")
    if not user.aktif:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Akun dinonaktifkan oleh admin")
    return _pasangan_token(user)


@router.post("/auth/refresh", response_model=Token)
def refresh(data: RefreshInput, db: DbSession):
    """Tukar refresh token yang masih berlaku dengan pasangan token baru."""
    gagal = HTTPException(status.HTTP_401_UNAUTHORIZED, "Sesi berakhir, silakan login lagi")
    try:
        payload = baca_token(data.refresh_token)
        if payload.get("jenis") != "refresh":
            raise gagal
        user = db.get(User, int(payload["sub"]))
    except (jwt.InvalidTokenError, KeyError, ValueError):
        raise gagal from None
    if user is None:
        raise gagal
    if not user.aktif:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Akun dinonaktifkan oleh admin")
    return _pasangan_token(user)


def _pasangan_token(user: User) -> Token:
    return Token(
        access_token=buat_access_token(user.id),
        refresh_token=buat_refresh_token(user.id),
    )


@router.get("/users/me", response_model=UserOut)
def profil_saya(user: UserAktif):
    return user


@router.patch("/users/me", response_model=UserOut)
def ubah_profil(data: UserUpdate, user: UserAktif, db: DbSession):
    """Contoh: {"target_harian": 25000}"""
    for kolom, nilai in data.model_dump(exclude_unset=True, exclude_none=True).items():
        setattr(user, kolom, nilai.strip() if isinstance(nilai, str) else nilai)
    db.commit()
    db.refresh(user)
    return user

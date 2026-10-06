from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select

from ..deps import DbSession, UserAktif
from ..models import User
from ..schemas import Token, UserCreate, UserOut
from ..security import buat_access_token, cek_password, hash_password

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
    return Token(access_token=buat_access_token(user.id))


@router.get("/users/me", response_model=UserOut)
def profil_saya(user: UserAktif):
    return user

from typing import Annotated

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from .database import get_db
from .models import User
from .security import baca_token

# tokenUrl dipakai tombol "Authorize" di Swagger UI (/docs).
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    """Dependency: membaca header `Authorization: Bearer <token>`."""
    gagal = HTTPException(
        status.HTTP_401_UNAUTHORIZED,
        "Token tidak valid atau sudah kedaluwarsa",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = baca_token(token)
        user_id = int(payload["sub"])
    except (jwt.InvalidTokenError, KeyError, ValueError):
        raise gagal from None
    user = db.get(User, user_id)
    if user is None:
        raise gagal
    if not user.aktif:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Akun dinonaktifkan oleh admin")
    return user


# Alias agar parameter endpoint lebih ringkas:
#   def endpoint(db: DbSession, user: UserAktif): ...
DbSession = Annotated[Session, Depends(get_db)]
UserAktif = Annotated[User, Depends(get_current_user)]

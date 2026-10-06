from datetime import datetime

from fastapi import APIRouter
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from ..database import engine

router = APIRouter(tags=["health"])


@router.get("/health")
def health():
    """Status API sekaligus koneksi database (503 bila database mati)."""
    waktu = datetime.now().isoformat(timespec="seconds")
    try:
        with engine.connect() as conn:
            versi = conn.execute(text("SELECT VERSION()")).scalar_one()
    except SQLAlchemyError as e:
        return JSONResponse(
            status_code=503,
            content={
                "status": "error",
                "waktu_server": waktu,
                "database": "error",
                "detail": str(e.__cause__ or e).splitlines()[0],
            },
        )
    return {
        "status": "ok",
        "waktu_server": waktu,
        "database": "ok",
        "mysql_version": versi,
    }

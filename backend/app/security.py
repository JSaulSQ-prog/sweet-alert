import os

from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from .supabase_client import supabase

bearer_scheme = HTTPBearer(
    auto_error=False,
    description="Access token que devuelve Supabase Auth al iniciar sesión"
)


DEMO_USER_ID = "00000000-0000-0000-0000-000000000000"


def get_current_user_id(credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme)) -> str:
    demo_mode = os.environ.get("DEV_SKIP_AUTH", "0") == "1"

    if credentials is None:
        if demo_mode:
            return DEMO_USER_ID
        raise HTTPException(401, "Token inválido")

    if credentials.credentials == "demo":
        return DEMO_USER_ID

    try:
        result = supabase.auth.get_user(credentials.credentials)
    except Exception:
        if demo_mode:
            return DEMO_USER_ID
        raise HTTPException(401, "Token inválido")

    if not result or not result.user:
        if demo_mode:
            return DEMO_USER_ID
        raise HTTPException(401, "Token inválido")

    return result.user.id

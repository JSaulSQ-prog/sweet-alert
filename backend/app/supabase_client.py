from supabase import create_client

from .config import SUPABASE_SERVICE_ROLE_KEY, SUPABASE_URL


class _FallbackAuth:
    def __init__(self, error_message: str):
        self._error_message = error_message

    def get_user(self, *_args, **_kwargs):
        raise RuntimeError(self._error_message)


class _FallbackSupabaseClient:
    def __init__(self, error_message: str):
        self.auth = _FallbackAuth(error_message)
        self._error_message = error_message

    def table(self, *_args, **_kwargs):
        raise RuntimeError(self._error_message)


try:
    supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
except Exception as exc:  # pragma: no cover - fallback for local/dev environments
    supabase = _FallbackSupabaseClient(str(exc))

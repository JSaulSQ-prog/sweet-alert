import uuid
import datetime
import json
from pathlib import Path

DATA_PATH = Path(__file__).resolve().parent.parent / ".demo_data.json"

def _load():
    if DATA_PATH.exists():
        try:
            with open(DATA_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {"profiles": {}, "assessments": {}}
    return {"profiles": {}, "assessments": {}}


def _save(data):
    try:
        with open(DATA_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception:
        pass


def get_demo_profile(user_id: str):
    data = _load()
    return data.get("profiles", {}).get(user_id)


def upsert_demo_profile(user_id: str, payload: dict):
    data = _load()
    p = dict(payload)
    p["id"] = user_id
    data.setdefault("profiles", {})[user_id] = p
    _save(data)
    return p


def insert_demo_assessment(row: dict):
    data = _load()
    r = dict(row)
    r.setdefault("id", str(uuid.uuid4()))
    r.setdefault("created_at", datetime.datetime.utcnow().isoformat() + "Z")
    user = r.get("user_id")
    data.setdefault("assessments", {}).setdefault(user, [])
    data["assessments"][user].insert(0, r)
    _save(data)
    return r


def list_demo_assessments(user_id: str):
    data = _load()
    return data.get("assessments", {}).get(user_id, [])

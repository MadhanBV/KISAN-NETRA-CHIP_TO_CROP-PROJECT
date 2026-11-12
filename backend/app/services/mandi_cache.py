"""SQLite Cache and Persistence for Mandi Market Prices."""

from datetime import datetime
import logging
import os
import sqlite3
from typing import Any, Dict, List, Optional

logger = logging.getLogger("chiptocrop.mandi_cache")

DB_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data")
DB_PATH = os.path.join(DB_DIR, "mandi_cache.db")


def get_connection() -> sqlite3.Connection:
    """Get a connection to the SQLite mandi cache database."""
    os.makedirs(DB_DIR, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_mandi_cache_db():
    """Initialize SQLite table for caching Government Agmarknet records."""
    try:
        with get_connection() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS mandi_prices_cache (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    state TEXT NOT NULL,
                    district TEXT,
                    market TEXT NOT NULL,
                    commodity TEXT NOT NULL,
                    variety TEXT,
                    grade TEXT,
                    arrival_date TEXT,
                    min_price REAL,
                    max_price REAL,
                    modal_price REAL,
                    commodity_code TEXT,
                    raw_json TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(state, market, commodity, variety, arrival_date)
                )
                """
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_mandi_lookup ON mandi_prices_cache(state, commodity)"
            )
            conn.commit()
    except Exception as e:
        logger.warning(f"Error initializing mandi cache database: {e}")


def _safe_float(val: Any) -> Optional[float]:
    """Safely convert numeric price or return None."""
    if val is None:
        return None
    if isinstance(val, (int, float)):
        return float(val)
    if isinstance(val, str):
        cleaned = val.replace(",", "").replace("₹", "").strip()
        if not cleaned or cleaned.upper() in ("NA", "N/A", "NULL", "NONE", "-", ""):
            return None
        try:
            return float(cleaned)
        except ValueError:
            return None
    return None


def cache_live_records(records: List[Dict[str, Any]]):
    """Insert or replace live records fetched from data.gov.in into local cache."""
    if not records:
        return
    try:
        init_mandi_cache_db()
        with get_connection() as conn:
            for r in records:
                state = r.get("state") or r.get("State")
                market = r.get("market") or r.get("Market")
                commodity = r.get("commodity") or r.get("Commodity")
                if not state or not market or not commodity:
                    continue

                district = r.get("district") or r.get("District")
                variety = r.get("variety") or r.get("Variety") or ""
                grade = r.get("grade") or r.get("Grade") or ""
                arrival_date = r.get("arrival_date") or r.get("Arrival_Date") or datetime.now().strftime("%d/%m/%Y")
                min_price_raw = r.get("min_price") if "min_price" in r else r.get("Min_Price")
                max_price_raw = r.get("max_price") if "max_price" in r else r.get("Max_Price")
                modal_price_raw = r.get("modal_price") if "modal_price" in r else r.get("Modal_Price")
                commodity_code = r.get("commodity_code") or r.get("Commodity_Code")

                conn.execute(
                    """
                    INSERT OR REPLACE INTO mandi_prices_cache
                    (state, district, market, commodity, variety, grade, arrival_date, min_price, max_price, modal_price, commodity_code)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        state,
                        district,
                        market,
                        commodity,
                        variety,
                        grade,
                        arrival_date,
                        _safe_float(min_price_raw),
                        _safe_float(max_price_raw),
                        _safe_float(modal_price_raw),
                        str(commodity_code) if commodity_code else None,
                    ),
                )
            conn.commit()
    except Exception as e:
        logger.warning(f"Failed to cache live mandi records: {e}")


def query_cached_records(
    state: Optional[str] = None,
    district: Optional[str] = None,
    commodity: Optional[str] = None,
    variety: Optional[str] = None,
    limit: int = 50,
) -> List[Dict[str, Any]]:
    """Query cached records matching filter criteria."""
    try:
        init_mandi_cache_db()
        with get_connection() as conn:
            query = "SELECT * FROM mandi_prices_cache WHERE 1=1"
            params: List[Any] = []

            if state and state.strip():
                query += " AND LOWER(state) = LOWER(?)"
                params.append(state.strip())

            if district and district.strip() and district.strip().lower() not in ("all", "all districts"):
                query += " AND LOWER(district) = LOWER(?)"
                params.append(district.strip())

            if commodity and commodity.strip() and commodity.strip().lower() not in ("all", "all commodities"):
                query += " AND LOWER(commodity) LIKE LOWER(?)"
                params.append(f"%{commodity.strip()}%")

            if variety and variety.strip():
                query += " AND LOWER(variety) LIKE LOWER(?)"
                params.append(f"%{variety.strip()}%")

            query += " ORDER BY id DESC LIMIT ?"
            params.append(limit)

            cursor = conn.cursor()
            rows = cursor.execute(query, params).fetchall()
            return [dict(row) for row in rows]
    except Exception as e:
        logger.warning(f"Error querying mandi cache: {e}")
        return []

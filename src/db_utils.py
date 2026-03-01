"""
Database utility functions for Olist E-Commerce Analytics.
Handles SQLite connection and query execution.
"""

import sqlite3
import pandas as pd
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "data" / "olist.db"


def get_connection() -> sqlite3.Connection:
    """Return a SQLite connection to the Olist database."""
    if not DB_PATH.exists():
        raise FileNotFoundError(
            f"Database not found at {DB_PATH}.\n"
            "Please run notebooks/00_setup.ipynb first to build the database."
        )
    return sqlite3.connect(DB_PATH)


def run_query(sql: str) -> pd.DataFrame:
    """Execute a SQL query and return results as a DataFrame."""
    with get_connection() as conn:
        return pd.read_sql_query(sql, conn)


def run_query_from_file(filepath: str) -> pd.DataFrame:
    """Read a .sql file and execute it, returning a DataFrame."""
    sql = Path(filepath).read_text(encoding="utf-8")
    return run_query(sql)

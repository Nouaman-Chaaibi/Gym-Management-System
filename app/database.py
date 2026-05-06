"""
Helpers to connect and call Oracle procedures/functions via oracledb
"""
from flask import current_app
import oracledb
import traceback


def get_db_connection():
    """Return a new oracledb connection using app config."""
    cfg = current_app.config
    user = cfg.get('ORACLE_USER')
    password = cfg.get('ORACLE_PASSWORD')
    host = cfg.get('ORACLE_HOST')
    port = cfg.get('ORACLE_PORT')
    service = cfg.get('ORACLE_SERVICE')

    dsn = f"{host}:{port}/{service}"
    try:
        conn = oracledb.connect(user=user, password=password, dsn=dsn)
        return conn
    except Exception:
        current_app.logger.exception('Erreur connexion Oracle')
        raise


def call_procedure(proc_name, params=None):
    """Call a stored procedure by name. params is a list/tuple.

    Returns the cursor.callproc result.
    """
    params = params or []
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        result = cur.callproc(proc_name, params)
        conn.commit()
        cur.close()
        conn.close()
        return result
    except oracledb.DatabaseError as e:
        if conn:
            try:
                conn.rollback()
            except Exception:
                pass
        # Extract Oracle error details
        error_obj, = e.args
        current_app.logger.error(f'Oracle Error calling {proc_name}: {error_obj.message}')
        traceback.print_exc()
        # Re-raise with more context
        raise Exception(f'Oracle Error in {proc_name}: {error_obj.message}')
    except Exception:
        if conn:
            try:
                conn.rollback()
            except Exception:
                pass
        traceback.print_exc()
        raise


def call_function(func_name, return_type, params=None):
    """Call a stored function and return its value.

    return_type should be a Python type or oracledb DB type compatible with cursor.callfunc.
    """
    params = params or []
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        result = cur.callfunc(func_name, return_type, params)
        cur.close()
        conn.close()
        return result
    except Exception:
        if conn:
            try:
                conn.rollback()
            except Exception:
                pass
        traceback.print_exc()
        raise

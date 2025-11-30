"""
Configuration de l'application Flask
"""
import os
from datetime import timedelta

class Config:
    """Classe de configuration"""
    
    # Configuration Flask
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    
    # Configuration de session
    PERMANENT_SESSION_LIFETIME = timedelta(hours=1)
    SESSION_TYPE = 'filesystem'
    
    # Configuration Oracle Database
    ORACLE_USER = os.getenv('DB_USER', 'admin_gym')
    ORACLE_PASSWORD = os.getenv('DB_PASSWORD', 'password')
    ORACLE_HOST = os.getenv('DB_HOST', 'localhost')
    ORACLE_PORT = os.getenv('DB_PORT', '1521')
    ORACLE_SERVICE = os.getenv('DB_SERVICE', 'XEPDB1')
    
    # Construire la chaîne de connexion Oracle
    # Format : oracle+cx_oracle://user:pass@host:port/?service_name=service
    # SQLALCHEMY_DATABASE_URI = (
    #     f"oracle+cx_oracle://{ORACLE_USER}:{ORACLE_PASSWORD}"
    #     f"@{ORACLE_HOST}:{ORACLE_PORT}/?service_name={ORACLE_SERVICE}"
    # )
    
    # Alternative avec oracledb (nouveau driver)
    SQLALCHEMY_DATABASE_URI = (
        f"oracle+oracledb://{ORACLE_USER}:{ORACLE_PASSWORD}"
        f"@{ORACLE_HOST}:{ORACLE_PORT}/?service_name={ORACLE_SERVICE}"
    )
    
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ECHO = True  # Afficher les requêtes SQL (dev only)
    
    # Configuration WTForms
    WTF_CSRF_ENABLED = True
    WTF_CSRF_TIME_LIMIT = None
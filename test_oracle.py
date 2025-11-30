import oracledb
import os
from dotenv import load_dotenv

load_dotenv()

try:
    # Connexion en mode Thin (pas besoin d'Oracle Instant Client si installé)
    connection = oracledb.connect(
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        dsn=f"{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_SERVICE')}"
    )

    print("✅ Connexion à Oracle réussie !")
    print(f"Version Oracle : {connection.version}")

    connection.close()
except Exception as e:
    print(f"❌ Erreur de connexion : {e}")

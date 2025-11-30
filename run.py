"""
Point d'entrée de l'application Gym Management
"""
from app import create_app

app = create_app()

if __name__ == '__main__':
    # Mode debug pour le développement
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )
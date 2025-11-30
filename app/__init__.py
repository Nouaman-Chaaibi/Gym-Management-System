"""
Initialisation de l'application Flask
"""
from flask import Flask
from flask_login import LoginManager
from dotenv import load_dotenv
import os
from flask_sqlalchemy import SQLAlchemy
from flask_wtf import CSRFProtect
from datetime import datetime, timedelta

# Charger les variables d'environnement
load_dotenv()

# Initialiser Flask-Login
login_manager = LoginManager()
# Initialiser SQLAlchemy et CSRF
db = SQLAlchemy()
csrf = CSRFProtect()

def create_app():
    """Factory pattern pour créer l'application Flask"""
    app = Flask(__name__, 
                template_folder='../templates',
                static_folder='../static')
    
    # Configuration
    app.config.from_object('app.config.Config')
    
    # Initialiser les extensions
    login_manager.init_app(app)
    login_manager.login_view = 'auth.login'
    login_manager.login_message = 'Veuillez vous connecter pour accéder à cette page.'
    login_manager.login_message_category = 'warning'
    # Init DB and CSRF
    db.init_app(app)
    csrf.init_app(app)
    
    # Context processor pour variables globales
    @app.context_processor
    def inject_globals():
        """Inject global variables into all templates"""
        return {
            'current_year': datetime.now().year,
            'now': datetime.now,
            'timedelta': timedelta  # Make timedelta available in templates
        }
    
    # Template filters
    @app.template_filter('format_datetime')
    def format_datetime_filter(dt):
        """Format datetime object to string"""
        if dt is None:
            return ''
        if isinstance(dt, datetime):
            return dt.strftime('%d/%m/%Y %H:%M')
        return str(dt)
    
    @app.template_filter('format_date')
    def format_date_filter(dt):
        """Format date object to string"""
        if dt is None:
            return ''
        if isinstance(dt, datetime):
            return dt.strftime('%d/%m/%Y')
        return str(dt)
    
    @app.template_filter('format_currency')
    def format_currency_filter(amount):
        """Format number as currency"""
        try:
            return f"{float(amount):.2f} €"
        except (ValueError, TypeError):
            return str(amount)
    
    # Enregistrer les blueprints (routes)
    from app.auth import auth_bp
    from app.routes.admin import admin_bp
    from app.routes.coach import coach_bp
    from app.routes.membre import membre_bp
    from app.routes.public import public_bp
    
    app.register_blueprint(auth_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(coach_bp)
    app.register_blueprint(membre_bp)
    app.register_blueprint(public_bp)
    
    return app
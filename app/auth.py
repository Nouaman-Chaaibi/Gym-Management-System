from flask import Blueprint, render_template, request, redirect, url_for, flash, current_app
from flask_login import login_user, logout_user, current_user
from app.models import User, Membre
from app import db, login_manager
from app.utils import hash_password, verify_password, handle_oracle_error
from datetime import datetime
from dateutil.relativedelta import relativedelta
import re

auth_bp = Blueprint('auth', __name__)


@login_manager.user_loader
def load_user(user_id):
    try:
        return User.query.get(int(user_id))
    except Exception:
        return None


@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('public.index'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = User.query.filter_by(username=username).first()
        
        if user and verify_password(password, user.password_hash):
            login_user(user)
            flash('Connexion réussie.', 'success')
            
            # Redirection par rôle
            if user.role == 'ADMIN':
                return redirect(url_for('admin.dashboard'))
            elif user.role == 'COACH':
                return redirect(url_for('coach.planning'))
            else:
                return redirect(url_for('membre.profil'))
        else:
            flash('Identifiants invalides.', 'danger')
    
    return render_template('auth/login.html')


@auth_bp.route('/logout')
def logout():
    logout_user()
    flash('Vous êtes déconnecté.', 'info')
    return redirect(url_for('public.index'))


@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('public.index'))
    
    if request.method == 'POST':
        nom = request.form.get('nom')
        prenom = request.form.get('prenom')
        email = request.form.get('email')
        telephone = request.form.get('telephone')
        date_naiss_str = request.form.get('date_naissance')
        adresse = request.form.get('adresse', '')
        password = request.form.get('password')
        password_confirm = request.form.get('password_confirm')

        # Server-side validations
        try:
            from datetime import date
            today = date.today().isoformat()
            
            # Validate email format
            email_pattern = r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'
            if not re.match(email_pattern, email.lower()):
                flash('Format d\'email invalide. Exemple: exemple@domaine.com', 'danger')
                return render_template('auth/register.html', today=today)
            
            # Validate phone format
            phone_pattern = r'^\+[0-9]{12}$'
            if not re.match(phone_pattern, telephone):
                flash('Format de téléphone invalide. Exemple: +212612345678 (+ suivi de 12 chiffres)', 'danger')
                return render_template('auth/register.html', today=today)
            
            # Validate password
            if len(password) < 8:
                flash('Le mot de passe doit contenir au moins 8 caractères.', 'danger')
                return render_template('auth/register.html', today=today)
            
            # Validate password confirmation
            if password != password_confirm:
                flash('Les mots de passe ne correspondent pas.', 'danger')
                return render_template('auth/register.html', today=today)
            
            # Validate date of birth (format only, age validation is done by trigger)
            if not date_naiss_str:
                flash('La date de naissance est obligatoire.', 'danger')
                return render_template('auth/register.html', today=today)
            
            date_naiss = datetime.strptime(date_naiss_str, '%Y-%m-%d').date()
            
            # Check date is in the past (basic validation, age check is done by trigger)
            if date_naiss >= datetime.now().date():
                flash('La date de naissance doit être dans le passé, pas dans le futur.', 'danger')
                return render_template('auth/register.html', today=today)
            
            # Hash password
            password_hashed = hash_password(password)
            
            # Check if email already exists
            existing_user = User.query.filter_by(username=email).first()
            if existing_user:
                flash('Un compte avec cet email existe déjà.', 'danger')
                return render_template('auth/register.html', today=today)
            
            # Create user with MEMBRE role
            new_user = User(
                username=email,
                password_hash=password_hashed,
                role='MEMBRE'
            )
            db.session.add(new_user)
            db.session.flush()  # Get user_id
            
            # Create membre record with INACTIF status
            new_membre = Membre(
                user_id=new_user.user_id,
                nom=nom,
                prenom=prenom,
                email=email,
                telephone=telephone,
                date_naissance=date_naiss,
                adresse=adresse,
                statut='INACTIF'  # Will become ACTIF after first subscription
            )
            db.session.add(new_membre)
            db.session.commit()
            
            flash('Inscription réussie! Vous pouvez maintenant vous connecter.', 'success')
            return redirect(url_for('auth.login'))
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.exception('Erreur inscription')
            flash(handle_oracle_error(e), 'danger')
            from datetime import date
            today = date.today().isoformat()
            return render_template('auth/register.html', today=today)
    
    from datetime import date
    today = date.today().isoformat()
    return render_template('auth/register.html', today=today)

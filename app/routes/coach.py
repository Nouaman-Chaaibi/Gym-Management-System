from flask import Blueprint, render_template, request, redirect, url_for, flash
from flask_login import current_user
from app.decorators import role_required
from app.models import Session, Coach, Membre
from app import db
from app.database import call_procedure
from app.utils import handle_oracle_error

coach_bp = Blueprint('coach', __name__, url_prefix='/coach')


@coach_bp.route('/planning')
@role_required('COACH')
def planning():
    try:
        # Get current coach
        coach = Coach.query.filter_by(user_id=current_user.user_id).first()
        if not coach:
            flash('Profil coach non trouvé.', 'danger')
            return redirect(url_for('public.index'))
        
        # Load sessions for current coach
        sessions = Session.query.filter_by(coach_id=coach.coach_id).order_by(Session.date_heure_debut.desc()).all()
        
        # Load member info for each session
        for session in sessions:
            session.membre_info = Membre.query.get(session.membre_id)
        
        return render_template('coach/planning.html', sessions=sessions, coach=coach)
    except Exception as e:
        return render_template('coach/planning.html', sessions=[], coach=None)


@coach_bp.route('/sessions')
@role_required('COACH')
def sessions():
    try:
        coach = Coach.query.filter_by(user_id=current_user.user_id).first()
        if not coach:
            return redirect(url_for('public.index'))
        
        sessions_list = Session.query.filter_by(coach_id=coach.coach_id).order_by(Session.date_heure_debut.desc()).all()
        
        for session in sessions_list:
            session.membre_info = Membre.query.get(session.membre_id)
        
        return render_template('coach/sessions.html', sessions=sessions_list, coach=coach)
    except Exception as e:
        return render_template('coach/sessions.html', sessions=[], coach=None)


@coach_bp.route('/sessions/<int:id>/confirmer')
@role_required('COACH')
def confirmer_session(id):
    try:
        session = Session.query.get(id)
        if session and session.coach_id == Coach.query.filter_by(user_id=current_user.user_id).first().coach_id:
            session.statut = 'CONFIRMEE'
            db.session.commit()
            flash('Session confirmée avec succès.', 'success')
        else:
            flash('Session non trouvée ou non autorisée.', 'danger')
    except Exception as e:
        flash('Erreur lors de la confirmation.', 'danger')
    
    return redirect(url_for('coach.sessions'))


@coach_bp.route('/sessions/<int:id>/annuler')
@role_required('COACH')
def annuler_session(id):
    try:
        session = Session.query.get(id)
        if session and session.coach_id == Coach.query.filter_by(user_id=current_user.user_id).first().coach_id:
            session.statut = 'ANNULEE'
            db.session.commit()
            flash('Session annulée.', 'warning')
        else:
            flash('Session non trouvée ou non autorisée.', 'danger')
    except Exception as e:
        flash('Erreur lors de l\'annulation.', 'danger')
    
    return redirect(url_for('coach.sessions'))


@coach_bp.route('/profil')
@role_required('COACH')
def profil():
    try:
        coach = Coach.query.filter_by(user_id=current_user.user_id).first()
        if not coach:
            flash('❌ Profil coach non trouvé.', 'danger')
            return redirect(url_for('public.index'))
        
        # Get statistics
        total_sessions = Session.query.filter_by(coach_id=coach.coach_id).count()
        sessions_confirmees = Session.query.filter_by(coach_id=coach.coach_id, statut='CONFIRMEE').count()
        
        stats = {
            'total_sessions': total_sessions,
            'sessions_confirmees': sessions_confirmees
        }
        
        return render_template('coach/profil.html', coach=coach, stats=stats)
    except Exception as e:
        return render_template('coach/profil.html', coach=None, stats={})


@coach_bp.route('/profil/modifier', methods=['GET', 'POST'])
@role_required('COACH')
def modifier_profil():
    """Edit coach profile information"""
    try:
        # Get current coach
        coach = Coach.query.filter_by(user_id=current_user.user_id).first()
        if not coach:
            flash('❌ Profil coach non trouvé.', 'danger')
            return redirect(url_for('public.index'))
        
        if request.method == 'POST':
            # Validate phone format
            import re
            telephone = request.form.get('telephone')
            phone_pattern = r'^\+[0-9]{12}$'
            if not re.match(phone_pattern, telephone):
                flash('⚠️ Format de téléphone invalide. Exemple: +212612345678', 'danger')
                return render_template('coach/profil_edit.html', coach=coach)
            
            # Get form data
            nom = request.form.get('nom')
            prenom = request.form.get('prenom')
            specialites = request.form.get('specialites', '')
            
            # Use stored procedure to update coach
            call_procedure('proc_modifier_coach', [
                coach.coach_id,
                nom,
                prenom,
                telephone,
                specialites,
                None  # email (non modifiable)
            ])
            
            # Refresh coach data
            db.session.refresh(coach)
            
            flash('✅ Profil mis à jour avec succès!', 'success')
            return redirect(url_for('coach.profil'))
        
        return render_template('coach/profil_edit.html', coach=coach)
    except Exception as e:
        db.session.rollback()
        flash(handle_oracle_error(e), 'danger')
        return redirect(url_for('coach.profil'))

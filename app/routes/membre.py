from flask import Blueprint, render_template, request, redirect, url_for, flash
from flask_login import current_user
from app.decorators import role_required
from app.models import Membre, Coach, Session, Souscription, Paiement, Acces, Abonnement
from app import db
from app.database import call_procedure
from app.utils import generate_reference, handle_oracle_error
from datetime import datetime, timedelta
import re

membre_bp = Blueprint('membre', __name__, url_prefix='/membre')


@membre_bp.route('/profil')
@role_required('MEMBRE')
def profil():
    try:
        # Get current member
        membre = Membre.query.filter_by(user_id=current_user.user_id).first()
        if not membre:
            flash('Profil membre non trouvé.', 'danger')
            return redirect(url_for('public.index'))
        
        # Get current subscription
        souscription_active = Souscription.query.filter_by(
            membre_id=membre.membre_id,
            statut='ACTIF'
        ).first()
        
        return render_template('membre/profil.html', membre=membre, souscription=souscription_active)
    except Exception as e:
        return render_template('membre/profil.html', membre=None, souscription=None)


@membre_bp.route('/profil/modifier', methods=['GET', 'POST'])
@role_required('MEMBRE')
def modifier_profil():
    """Edit member profile information"""
    try:
        # Get current member
        membre = Membre.query.filter_by(user_id=current_user.user_id).first()
        if not membre:
            flash('❌ Profil membre non trouvé.', 'danger')
            return redirect(url_for('public.index'))
        
        if request.method == 'POST':
            # Validate phone format
            telephone = request.form.get('telephone')
            phone_pattern = r'^\+[0-9]{12}$'
            if not re.match(phone_pattern, telephone):
                flash('⚠️ Format de téléphone invalide. Exemple: +212612345678', 'danger')
                from datetime import date
                today = date.today().isoformat()
                return render_template('membre/profil_edit.html', membre=membre, today=today)
            
            # Get form data
            nom = request.form.get('nom')
            prenom = request.form.get('prenom')
            adresse = request.form.get('adresse', '')
            date_naiss_str = request.form.get('date_naissance')
            
            # Parse date_naissance if provided
            date_naissance = None
            if date_naiss_str:
                date_naissance = datetime.strptime(date_naiss_str, '%Y-%m-%d').date()
            
            # Use stored procedure to update member
            call_procedure('proc_modifier_membre', [
                membre.membre_id,
                nom,
                prenom,
                telephone,
                adresse,
                None,  # email (non modifiable)
                date_naissance,
                None   # statut (non modifiable par le membre)
            ])
            
            # Refresh member data
            db.session.refresh(membre)
            
            flash('✅ Profil mis à jour avec succès!', 'success')
            return redirect(url_for('membre.profil'))
        
        from datetime import date
        today = date.today().isoformat()
        return render_template('membre/profil_edit.html', membre=membre, today=today)
    except Exception as e:
        db.session.rollback()
        flash(handle_oracle_error(e), 'danger')
        return redirect(url_for('membre.profil'))


@membre_bp.route('/souscrire/<int:abonnement_id>', methods=['POST'])
@role_required('MEMBRE')
def souscrire(abonnement_id):
    """Subscribe member to an abonnement plan"""
    try:
        # Get current member
        membre = Membre.query.filter_by(user_id=current_user.user_id).first()
        if not membre:
            flash('Profil membre non trouvé.', 'danger')
            return redirect(url_for('public.index'))
        
        # Get abonnement details
        abonnement = Abonnement.query.get(abonnement_id)
        if not abonnement or abonnement.actif != 'O':
            flash('Abonnement non disponible.', 'danger')
            return redirect(url_for('public.abonnements'))
        
        # Call stored procedure to create subscription
        call_procedure('proc_souscrire_abonnement', [membre.membre_id, abonnement_id])
        
        # Get the newly created subscription
        nouvelle_souscription = Souscription.query.filter_by(
            membre_id=membre.membre_id
        ).order_by(Souscription.date_souscription.desc()).first()
        
        if nouvelle_souscription:
            # Create payment for this subscription
            reference = generate_reference('PAY')
            nouveau_paiement = Paiement(
                souscription_id=nouvelle_souscription.souscription_id,
                montant=abonnement.prix,
                methode_paiement='CARTE',
                statut_paiement='VALIDE',
                reference=reference
            )
            db.session.add(nouveau_paiement)
            
            # Update subscription status to ACTIF
            nouvelle_souscription.statut = 'ACTIF'
            
            # Update member status to ACTIF
            membre.statut = 'ACTIF'
            
            db.session.commit()
            
            flash(f'Abonnement {abonnement.nom} souscrit avec succès! Référence: {reference}', 'success')
        else:
            flash('Erreur lors de la création de la souscription.', 'danger')
        
        return redirect(url_for('membre.profil'))
    except Exception as e:
        db.session.rollback()
        flash(f'Erreur lors de la souscription: {str(e)[:200]}', 'danger')
        return redirect(url_for('public.abonnements'))


@membre_bp.route('/reserver', methods=['GET', 'POST'])
@role_required('MEMBRE')
def reserver():
    if request.method == 'POST':
        try:
            membre = Membre.query.filter_by(user_id=current_user.user_id).first()
            if not membre:
                flash('Profil non trouvé.', 'danger')
                return redirect(url_for('public.index'))
            
            # Check if member has active subscription
            souscription_active = Souscription.query.filter_by(
                membre_id=membre.membre_id,
                statut='ACTIF'
            ).filter(Souscription.date_fin >= datetime.now().date()).first()
            
            if not souscription_active:
                flash('Vous devez d\'abord souscrire à un abonnement valide pour réserver une session.', 'warning')
                return redirect(url_for('public.abonnements'))
            
            coach_id = request.form.get('coach_id')
            date_str = request.form.get('date')
            time_str = request.form.get('time')
            type_session = request.form.get('type', 'Individuelle')
            
            # Create datetime from date and time
            datetime_str = f"{date_str} {time_str}"
            date_heure_debut = datetime.strptime(datetime_str, '%Y-%m-%d %H:%M')
            date_heure_fin = datetime(date_heure_debut.year, date_heure_debut.month, 
                                     date_heure_debut.day, date_heure_debut.hour + 1, 
                                     date_heure_debut.minute)
            
            # Create new session
            new_session = Session(
                membre_id=membre.membre_id,
                coach_id=int(coach_id),
                date_heure_debut=date_heure_debut,
                date_heure_fin=date_heure_fin,
                type_session=type_session,
                statut='RESERVEE'
            )
            
            db.session.add(new_session)
            db.session.commit()
            
            flash('Session réservée avec succès!', 'success')
            return redirect(url_for('membre.sessions'))
        except Exception as e:
            db.session.rollback()
            flash(f'Erreur lors de la réservation: {str(e)[:100]}', 'danger')
    
    # GET request - show form
    try:
        coaches = Coach.query.filter_by(actif='O').all()
        return render_template('membre/reserver.html', coaches=coaches)
    except Exception as e:
        return render_template('membre/reserver.html', coaches=[])


@membre_bp.route('/sessions')
@role_required('MEMBRE')
def sessions():
    try:
        membre = Membre.query.filter_by(user_id=current_user.user_id).first()
        if not membre:
            return redirect(url_for('public.index'))
        
        sessions_list = Session.query.filter_by(membre_id=membre.membre_id).order_by(Session.date_heure_debut.desc()).all()
        
        # Load coach info for each session
        for session in sessions_list:
            session.coach_info = Coach.query.get(session.coach_id)
        
        paiements = Paiement.query.join(Souscription).filter(
            Souscription.membre_id == membre.membre_id
        ).order_by(Paiement.date_paiement.desc()).all()
        
        acces_list = Acces.query.filter_by(membre_id=membre.membre_id).order_by(Acces.date_heure_entree.desc()).all()
        
        return render_template('membre/historique.html', 
                             sessions=sessions_list, 
                             paiements=paiements, 
                             acces=acces_list)
    except Exception as e:
        return render_template('membre/historique.html', sessions=[], paiements=[], acces=[])


@membre_bp.route('/paiements')
@role_required('MEMBRE')
def paiements():
    return redirect(url_for('membre.sessions'))


@membre_bp.route('/acces')
@role_required('MEMBRE')
def acces():
    """Redirect to sessions page with acces tab active"""
    return redirect(url_for('membre.sessions') + '#acces')


@membre_bp.route('/renouveler', methods=['POST'])
@role_required('MEMBRE')
def renouveler():
    flash('Fonctionnalité de renouvellement à venir. Contactez l\'administration.', 'info')
    return redirect(url_for('membre.profil'))

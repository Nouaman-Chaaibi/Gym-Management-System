from flask import Blueprint, render_template, flash, redirect, url_for, request, send_file
from app.decorators import role_required
from app.models import Membre, Abonnement, Souscription, Paiement, Session, User, Acces
from app import db
from app.utils import hash_password, handle_oracle_error
from app.database import call_procedure
from sqlalchemy import func, extract
from datetime import datetime, date
import csv
import io

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')


@admin_bp.route('/dashboard')
@role_required('ADMIN')
def dashboard():
    try:
        # Calculate actual statistics from database
        membres_actifs = Membre.query.filter_by(statut='ACTIF').count()
        
        # Revenue this month
        current_month = datetime.now().month
        current_year = datetime.now().year
        revenus_mois = db.session.query(func.sum(Paiement.montant)).filter(
            extract('month', Paiement.date_paiement) == current_month,
            extract('year', Paiement.date_paiement) == current_year,
            Paiement.statut_paiement == 'VALIDE'
        ).scalar() or 0
        
        # Sessions today
        today = date.today()
        sessions_aujourd_hui = Session.query.filter(
            func.trunc(Session.date_heure_debut) == today
        ).count()
        
        # Recent payments
        recent_payments = Paiement.query.order_by(Paiement.date_paiement.desc()).limit(10).all()
        
        stats = {
            'membres_actifs': membres_actifs,
            'revenus_mois': float(revenus_mois),
            'sessions_aujourd_hui': sessions_aujourd_hui
        }
        
        return render_template('admin/dashboard.html', stats=stats, recent_payments=recent_payments)
    except Exception as e:
        # Fallback to placeholder data if database error
        stats = {
            'membres_actifs': 0,
            'revenus_mois': 0.00,
            'sessions_aujourd_hui': 0
        }
        return render_template('admin/dashboard.html', stats=stats, recent_payments=[])


@admin_bp.route('/membres')
@role_required('ADMIN')
def membres():
    try:
        # Get status filter from query params
        statut_filter = request.args.get('statut', 'TOUS')
        
        # Build query
        query = Membre.query
        if statut_filter and statut_filter != 'TOUS':
            query = query.filter(Membre.statut == statut_filter)
        
        membres_list = query.order_by(Membre.date_inscription.desc()).all()
        return render_template('admin/membres.html', membres=membres_list, statut_filter=statut_filter)
    except Exception as e:
        return render_template('admin/membres.html', membres=[], statut_filter='TOUS')


@admin_bp.route('/membres/export')
@role_required('ADMIN')
def export_membres():
    """Export members to CSV file"""
    try:
        membres_list = Membre.query.order_by(Membre.nom).all()
        
        # Create CSV in memory
        output = io.StringIO()
        writer = csv.writer(output)
        
        # Write header
        writer.writerow(['ID', 'Nom', 'Prénom', 'Email', 'Téléphone', 'Date Inscription', 'Statut'])
        
        # Write data
        for membre in membres_list:
            writer.writerow([
                membre.membre_id,
                membre.nom,
                membre.prenom,
                membre.email,
                membre.telephone,
                membre.date_inscription.strftime('%d/%m/%Y') if membre.date_inscription else '',
                membre.statut
            ])
        
        # Prepare file for download
        output.seek(0)
        return send_file(
            io.BytesIO(output.getvalue().encode('utf-8')),
            mimetype='text/csv',
            as_attachment=True,
            download_name=f'membres_{datetime.now().strftime("%Y%m%d")}.csv'
        )
    except Exception as e:
        flash(f'Erreur lors de l\'export: {str(e)[:100]}', 'danger')
        return redirect(url_for('admin.membres'))


@admin_bp.route('/membres/<int:membre_id>')
@role_required('ADMIN')
def voir_membre(membre_id):
    """View member details"""
    try:
        membre = Membre.query.get_or_404(membre_id)
        
        # Get member's souscriptions
        souscriptions = Souscription.query.filter_by(membre_id=membre_id).order_by(Souscription.date_souscription.desc()).all()
        
        # Get member's sessions
        sessions = Session.query.filter_by(membre_id=membre_id).order_by(Session.date_heure_debut.desc()).limit(10).all()
        
        return render_template('admin/membre_detail.html', membre=membre, souscriptions=souscriptions, sessions=sessions)
    except Exception as e:
        flash('Membre non trouvé.', 'danger')
        return redirect(url_for('admin.membres'))


@admin_bp.route('/membres/<int:membre_id>/modifier', methods=['GET', 'POST'])
@role_required('ADMIN')
def modifier_membre(membre_id):
    """Edit member information"""
    try:
        membre = Membre.query.get_or_404(membre_id)
        
        if request.method == 'POST':
            # Get form data
            nom = request.form.get('nom')
            prenom = request.form.get('prenom')
            telephone = request.form.get('telephone')
            adresse = request.form.get('adresse')
            statut = request.form.get('statut')
            date_naiss_str = request.form.get('date_naissance')
            
            # Parse date_naissance if provided
            date_naissance = None
            if date_naiss_str:
                date_naissance = datetime.strptime(date_naiss_str, '%Y-%m-%d').date()
            
            # Use stored procedure to update member
            call_procedure('proc_modifier_membre', [
                membre_id,
                nom,
                prenom,
                telephone,
                adresse,
                None,  # email (non modifiable par admin pour l'instant)
                date_naissance,
                statut
            ])
            
            # Refresh member data
            db.session.refresh(membre)
            
            flash('✅ Membre modifié avec succès!', 'success')
            return redirect(url_for('admin.voir_membre', membre_id=membre_id))
        
        from datetime import date
        max_date = date.today().isoformat()
        return render_template('admin/membre_form.html', membre=membre, action='Modifier', max_date=max_date)
    except Exception as e:
        db.session.rollback()
        flash(handle_oracle_error(e), 'danger')
        return redirect(url_for('admin.membres'))


@admin_bp.route('/membres/ajouter', methods=['GET', 'POST'])
@role_required('ADMIN')
def ajouter_membre():
    """Add new member"""
    if request.method == 'POST':
        try:
            # Get form data
            email = request.form.get('email')
            password = request.form.get('password', 'Welcome123')  # Default password
            
            # Validate email format
            import re
            email_pattern = r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'
            if not re.match(email_pattern, email.lower()):
                flash('Format d\'email invalide.', 'danger')
                return render_template('admin/membre_form.html', membre=None, action='Ajouter')
            
            # Check if user exists
            existing_user = User.query.filter_by(username=email).first()
            if existing_user:
                flash('📧 Un compte avec cet email existe déjà.', 'danger')
                return render_template('admin/membre_form.html', membre=None, action='Ajouter')
            
            # Check if member with this email exists
            existing_membre = Membre.query.filter_by(email=email).first()
            if existing_membre:
                flash('📧 Un membre avec cet email existe déjà.', 'danger')
                from datetime import date
                max_date = date.today().isoformat()
                return render_template('admin/membre_form.html', membre=None, action='Ajouter', max_date=max_date)
            
            # Check if telephone is already used
            telephone = request.form.get('telephone')
            existing_phone = Membre.query.filter_by(telephone=telephone).first()
            if existing_phone:
                flash('📞 Ce numéro de téléphone est déjà utilisé.', 'danger')
                from datetime import date
                max_date = date.today().isoformat()
                return render_template('admin/membre_form.html', membre=None, action='Ajouter', max_date=max_date)
            
            # Validate date_naissance
            date_naiss_str = request.form.get('date_naissance')
            if not date_naiss_str:
                flash('La date de naissance est obligatoire.', 'danger')
                from datetime import date
                max_date = date.today().isoformat()
                return render_template('admin/membre_form.html', membre=None, action='Ajouter', max_date=max_date)
            
            date_naiss = datetime.strptime(date_naiss_str, '%Y-%m-%d').date()
            
            # Create user account first
            new_user = User(
                username=email,
                password_hash=hash_password(password),
                role='MEMBRE'
            )
            db.session.add(new_user)
            db.session.flush()  # Get the user_id
            
            print(f"DEBUG: Created user with user_id={new_user.user_id}")
            
            # Check if this user_id is already used by another member
            existing_member_with_userid = Membre.query.filter_by(user_id=new_user.user_id).first()
            if existing_member_with_userid:
                db.session.rollback()
                flash(f'🔑 Erreur interne: user_id {new_user.user_id} est déjà utilisé par membre {existing_member_with_userid.membre_id}', 'danger')
                from datetime import date
                max_date = date.today().isoformat()
                return render_template('admin/membre_form.html', membre=None, action='Ajouter', max_date=max_date)
            
            # Create member using direct INSERT
            new_membre = Membre(
                user_id=new_user.user_id,
                nom=request.form.get('nom'),
                prenom=request.form.get('prenom'),
                email=email,
                telephone=telephone,
                date_naissance=date_naiss,
                adresse=request.form.get('adresse', ''),
                statut='INACTIF'
            )
            db.session.add(new_membre)
            
            print(f"DEBUG: Creating membre with user_id={new_membre.user_id}, email={new_membre.email}")
            
            db.session.commit()
            
            flash(f'✅ Membre ajouté avec succès! Mot de passe: {password}', 'success')
            return redirect(url_for('admin.membres'))
        except Exception as e:
            db.session.rollback()
            flash(handle_oracle_error(e), 'danger')
            from datetime import date
            max_date = date.today().isoformat()
            return render_template('admin/membre_form.html', membre=None, action='Ajouter', max_date=max_date)
    
    from datetime import date
    max_date = date.today().isoformat()
    return render_template('admin/membre_form.html', membre=None, action='Ajouter', max_date=max_date)


@admin_bp.route('/membres/<int:membre_id>/supprimer', methods=['POST'])
@role_required('ADMIN')
def supprimer_membre(membre_id):
    """Delete member (actually just deactivate)"""
    try:
        membre = Membre.query.get_or_404(membre_id)
        
        # Instead of deleting, deactivate
        membre.statut = 'INACTIF'
        
        # Also deactivate user account
        if membre.user_id:
            user = User.query.get(membre.user_id)
            if user:
                user.actif = 'N'
        
        db.session.commit()
        flash('Membre désactivé avec succès.', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'Erreur: {str(e)[:100]}', 'danger')
    
    return redirect(url_for('admin.membres'))


@admin_bp.route('/abonnements')
@role_required('ADMIN')
def abonnements():
    try:
        # Load all subscriptions
        abonnements_list = Abonnement.query.order_by(Abonnement.prix).all()
        
        # Get subscription counts
        for abo in abonnements_list:
            abo.souscription_count = Souscription.query.filter_by(
                abonnement_id=abo.abonnement_id,
                statut='ACTIF'
            ).count()
        
        return render_template('admin/abonnements.html', abonnements=abonnements_list)
    except Exception as e:
        return render_template('admin/abonnements.html', abonnements=[])


@admin_bp.route('/paiements')
@role_required('ADMIN')
def paiements():
    try:
        # Get all payments with member info
        paiements_list = Paiement.query.join(Souscription).join(Membre).order_by(Paiement.date_paiement.desc()).all()
        return render_template('admin/paiements.html', paiements=paiements_list)
    except Exception as e:
        return render_template('admin/paiements.html', paiements=[])


@admin_bp.route('/acces', methods=['GET', 'POST'])
@role_required('ADMIN')
def controle_acces():
    """Control access to the gym (check-in/check-out)"""
    try:
        # Handle POST requests (check-in/check-out)
        if request.method == 'POST':
            action = request.form.get('action')
            
            if action == 'checkin':
                # Get membre by ID, email, or telephone
                membre_id = request.form.get('membre_id')
                email = request.form.get('email', '').strip()
                telephone = request.form.get('telephone', '').strip()
                
                membre = None
                if membre_id:
                    membre = Membre.query.get(membre_id)
                elif email:
                    membre = Membre.query.filter_by(email=email).first()
                elif telephone:
                    membre = Membre.query.filter_by(telephone=telephone).first()
                
                if not membre:
                    flash('❌ Membre non trouvé. Vérifiez l\'ID, l\'email ou le numéro de téléphone.', 'danger')
                    return redirect(url_for('admin.controle_acces'))
                
                # Enregistrer l'accès via procédure
                call_procedure('proc_enregistrer_acces', [membre.membre_id])
                flash(f'✅ Entrée enregistrée pour {membre.nom} {membre.prenom}', 'success')
            
            elif action == 'checkout':
                acces_id = request.form.get('acces_id')
                if acces_id:
                    try:
                        call_procedure('proc_enregistrer_sortie', [int(acces_id)])
                        flash('✅ Sortie enregistrée avec succès', 'success')
                    except Exception as e:
                        flash(handle_oracle_error(e), 'danger')
                else:
                    flash('❌ ID d\'accès manquant', 'danger')
        
        # GET request - display access control interface
        # Get current accesses (EN_COURS)
        acces_en_cours = Acces.query.filter_by(statut_acces='EN_COURS').order_by(Acces.date_heure_entree.desc()).all()
        
        # Load member info for each access
        for acces in acces_en_cours:
            acces.membre = Membre.query.get(acces.membre_id)
        
        # Get access history (last 50)
        historique = Acces.query.order_by(Acces.date_heure_entree.desc()).limit(50).all()
        
        # Load member info for history
        for acces in historique:
            acces.membre = Membre.query.get(acces.membre_id)
        
        return render_template('admin/acces.html', 
                             acces_en_cours=acces_en_cours,
                             historique=historique)
    
    except Exception as e:
        db.session.rollback()
        flash(handle_oracle_error(e), 'danger')
        # En cas d'erreur, recharger les données pour afficher la page
        try:
            acces_en_cours = Acces.query.filter_by(statut_acces='EN_COURS').order_by(Acces.date_heure_entree.desc()).all()
            for acces in acces_en_cours:
                acces.membre = Membre.query.get(acces.membre_id)
            historique = Acces.query.order_by(Acces.date_heure_entree.desc()).limit(50).all()
            for acces in historique:
                acces.membre = Membre.query.get(acces.membre_id)
            return render_template('admin/acces.html', 
                                 acces_en_cours=acces_en_cours,
                                 historique=historique)
        except:
            return render_template('admin/acces.html', acces_en_cours=[], historique=[])

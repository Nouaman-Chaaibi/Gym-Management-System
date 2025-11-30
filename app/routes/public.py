from flask import Blueprint, render_template

public_bp = Blueprint('public', __name__)


@public_bp.route('/')
def index():
    return render_template('public/index.html')


@public_bp.route('/about')
def about():
    return render_template('public/about.html')


@public_bp.route('/abonnements')
def abonnements():
    from app.models import Abonnement
    from app import db
    
    # Load active subscriptions from database
    try:
        abonnements_list = Abonnement.query.filter_by(actif='O').order_by(Abonnement.prix).all()
    except Exception as e:
        abonnements_list = []
        
    return render_template('public/abonnements.html', abonnements=abonnements_list)

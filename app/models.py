"""SQLAlchemy models for the Gym Management System
Models align with actual Oracle schema in database/shema.sql
"""
from datetime import datetime
from flask_login import UserMixin
from app import db


class User(db.Model, UserMixin):
    __tablename__ = 'auth_users'
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    role = db.Column(db.String(20), nullable=False, default='MEMBRE')
    date_creation = db.Column(db.Date, default=datetime.utcnow)
    dernier_login = db.Column(db.DateTime)
    actif = db.Column(db.String(1), default='O', nullable=False)

    def get_id(self):
        return str(self.user_id)
    
    def is_active(self):
        return self.actif == 'O'


class Membre(db.Model):
    __tablename__ = 'membres'
    membre_id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(50), nullable=False)
    prenom = db.Column(db.String(50), nullable=False)
    date_naissance = db.Column(db.Date, nullable=False)
    email = db.Column(db.String(100), nullable=False, unique=True)
    telephone = db.Column(db.String(20), nullable=False)
    adresse = db.Column(db.String(200))
    date_inscription = db.Column(db.Date, default=datetime.utcnow)
    statut = db.Column(db.String(20), default='ACTIF')
    user_id = db.Column(db.Integer, db.ForeignKey('auth_users.user_id'), nullable=False, unique=True)

    user = db.relationship('User', backref=db.backref('membre', uselist=False))
    souscriptions = db.relationship('Souscription', backref='membre', lazy=True)
    sessions = db.relationship('Session', backref='membre', lazy=True)
    acces = db.relationship('Acces', backref='membre', lazy=True)


class Coach(db.Model):
    __tablename__ = 'coachs'
    coach_id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(50), nullable=False)
    prenom = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(100), nullable=False, unique=True)
    telephone = db.Column(db.String(20), nullable=False)
    specialites = db.Column(db.String(200), nullable=False)
    salaire_horaire = db.Column(db.Numeric(10, 2), nullable=False)
    date_embauche = db.Column(db.Date, default=datetime.utcnow)
    actif = db.Column(db.String(1), default='O')
    user_id = db.Column(db.Integer, db.ForeignKey('auth_users.user_id'), nullable=False, unique=True)

    user = db.relationship('User', backref=db.backref('coach', uselist=False))
    sessions = db.relationship('Session', backref='coach', lazy=True)


class Abonnement(db.Model):
    __tablename__ = 'abonnements'
    abonnement_id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(50), nullable=False, unique=True)
    description = db.Column(db.String(200))
    duree_mois = db.Column(db.Integer, nullable=False)
    prix = db.Column(db.Numeric(10, 2), nullable=False)
    type_abonnement = db.Column(db.String(20), nullable=False)
    nombre_sessions_incluses = db.Column(db.Integer, default=0)
    date_creation = db.Column(db.Date, default=datetime.utcnow)
    actif = db.Column(db.String(1), default='O')

    souscriptions = db.relationship('Souscription', backref='abonnement', lazy=True)


class Souscription(db.Model):
    __tablename__ = 'souscriptions'
    souscription_id = db.Column(db.Integer, primary_key=True)
    membre_id = db.Column(db.Integer, db.ForeignKey('membres.membre_id'), nullable=False)
    abonnement_id = db.Column(db.Integer, db.ForeignKey('abonnements.abonnement_id'), nullable=False)
    date_debut = db.Column(db.Date, nullable=False)
    date_fin = db.Column(db.Date, nullable=False)
    statut = db.Column(db.String(20), default='EN_ATTENTE')
    date_souscription = db.Column(db.Date, default=datetime.utcnow)
    sessions_restantes = db.Column(db.Integer, default=0)

    paiements = db.relationship('Paiement', backref='souscription', lazy=True)


class Paiement(db.Model):
    __tablename__ = 'paiements'
    paiement_id = db.Column(db.Integer, primary_key=True)
    souscription_id = db.Column(db.Integer, db.ForeignKey('souscriptions.souscription_id'), nullable=False)
    montant = db.Column(db.Numeric(10, 2), nullable=False)
    date_paiement = db.Column(db.Date, default=datetime.utcnow)
    methode_paiement = db.Column(db.String(20), nullable=False)
    statut_paiement = db.Column(db.String(20), default='VALIDE')
    reference = db.Column(db.String(50), unique=True)


class Session(db.Model):
    __tablename__ = 'sessions'
    session_id = db.Column(db.Integer, primary_key=True)
    membre_id = db.Column(db.Integer, db.ForeignKey('membres.membre_id'), nullable=False)
    coach_id = db.Column(db.Integer, db.ForeignKey('coachs.coach_id'), nullable=False)
    date_heure_debut = db.Column(db.DateTime, nullable=False)
    date_heure_fin = db.Column(db.DateTime, nullable=False)
    type_session = db.Column(db.String(50), nullable=False)
    statut = db.Column(db.String(20), default='RESERVEE')
    notes = db.Column(db.String(500))
    date_reservation = db.Column(db.Date, default=datetime.utcnow)


class Acces(db.Model):
    __tablename__ = 'acces'
    acces_id = db.Column(db.Integer, primary_key=True)
    membre_id = db.Column(db.Integer, db.ForeignKey('membres.membre_id'), nullable=False)
    date_heure_entree = db.Column(db.DateTime, default=datetime.utcnow)
    date_heure_sortie = db.Column(db.DateTime)
    statut_acces = db.Column(db.String(20), default='EN_COURS')
    motif_refus = db.Column(db.String(200))

# Gym Management System

Application de gestion de salle de sport développée avec Flask et Oracle Database.

## Prérequis

- Python 3.9+
- Oracle Database 19c ou 21c XE
- Oracle Instant Client (pour cx_Oracle)

## Installation

1. Cloner le projet
```bash
git clone <url-du-repo>
cd gym-management
```

2. Créer et activer l'environnement virtuel
```bash
python -m venv venv
# Windows
.\venv\Scripts\activate
# Linux/Mac
source venv/bin/activate
```

3. Installer les dépendances
```bash
pip install -r requirements.txt
```

4. Configurer les variables d'environnement
Copier `.env.example` vers `.env` et remplir les valeurs.

5. Initialiser la base de données
Exécuter les scripts SQL dans l'ordre :
```sql
@database/schema.sql
@database/procedures.sql
@database/fonctions.sql
@database/procedures.sql
@database/triggers.sql
@database/vues.sql
@database/users_et_priveleges.sql
@database/test_data.sql
```

6. Lancer l'application
```bash
python run.py
```

L'application sera accessible sur http://localhost:5000

## Structure du Projet
```
gym-management/
├── app/                # Code application Flask
├── database/           # Scripts SQL
├── templates/          # Templates HTML
├── static/             # Fichiers statiques (CSS, JS, images)
└── docs/              # Documentation
```

## Fonctionnalités

- Gestion des membres et abonnements
- Système de réservation de sessions de coaching
- Contrôle d'accès à la salle
- Gestion des paiements
- Tableaux de bord par rôle (Admin, Coach, Membre)

## Technologies

- **Backend** : Flask, SQLAlchemy
- **Base de données** : Oracle Database 21c XE
- **Frontend** : HTML, Bootstrap 5, Jinja2
- **Authentification** : Flask-Login, bcrypt

## Auteur

Nouaman CHAAIBI 
"""Utility functions: password hashing, formatting, reference generation."""
import bcrypt
from uuid import uuid4
from datetime import datetime


def hash_password(password: str) -> str:
    """Hash a plain text password using bcrypt."""
    if isinstance(password, str):
        password = password.encode('utf-8')
    hashed = bcrypt.hashpw(password, bcrypt.gensalt())
    return hashed.decode('utf-8')


def verify_password(password: str, hashed: str) -> bool:
    """Verify password against a hash. Handles both bcrypt hashes and plain text (for demo)."""
    if isinstance(password, str):
        password = password.encode('utf-8')
    if isinstance(hashed, str):
        hashed = hashed.encode('utf-8')
    
    # Check if it's a bcrypt hash (starts with $2a$, $2b$, or $2y$)
    try:
        if hashed.startswith(b'$2'):
            return bcrypt.checkpw(password, hashed)
        else:
            # Plain text comparison (for demo password like 'password_demo')
            return password.decode('utf-8') == hashed.decode('utf-8')
    except Exception:
        return False


def generate_reference(prefix: str = 'PAY') -> str:
    """Generate a short unique payment reference using UUID4."""
    return f"{prefix}-{uuid4().hex[:12].upper()}"


def format_date(dt: datetime) -> str:
    if dt is None:
        return ''
    return dt.strftime('%Y-%m-%d %H:%M') if isinstance(dt, datetime) else str(dt)


def format_currency(amount) -> str:
    try:
        return f"{float(amount):.2f} €"
    except Exception:
        return str(amount)


def handle_oracle_error(error):
    """
    Convertit les erreurs Oracle en messages user-friendly
    
    Args:
        error: Exception Oracle (oracledb.exceptions.IntegrityError, etc.)
    
    Returns:
        str: Message clair avec emoji pour l'utilisateur
    """
    error_str = str(error)
    
    # Mapping des codes d'erreur Oracle vers messages FR
    error_messages = {
        'ORA-20001': '🎂 Vous devez avoir au moins 16 ans pour vous inscrire.',
        'ORA-20002': '📧 Cet email est déjà utilisé.',
        'ORA-20003': '🚫 Le membre a une souscription active.',
        'ORA-20004': '⚠️ Souscription non en attente de paiement.',
        'ORA-20005': '💰 Montant incorrect pour le paiement.',
        'ORA-20006': '🚫 Abonnement invalide pour cette opération.',
        'ORA-20007': '⏰ Coach indisponible pour ce créneau.',
        'ORA-20008': '👥 Conflit horaire détecté pour cette session.',
        'ORA-20009': '⏰ Annulation interdite moins de 12h avant la session.',
        'ORA-20010': '🚫 Vous n\'avez pas d\'abonnement valide.',
        'ORA-20011': '⏰ Ce créneau horaire n\'est pas disponible.',
        'ORA-20012': '👥 Conflit horaire détecté pour cette session.',
        'ORA-20015': '⚠️ Coach a des sessions à venir.',
        'ORA-20020': '🔒 Accès refusé : Votre abonnement est expiré ou inactif.',
        'ORA-20021': '🕐 La salle est fermée. Horaires d\'ouverture: 6h-23h.',
        'ORA-20022': '⚠️ Vous avez déjà un accès en cours. Veuillez enregistrer la sortie d\'abord.',
        'ORA-20030': '⚠️ Cet accès est déjà terminé ou n\'existe pas.',
        'ORA-20031': '👤 Ce membre est déjà présent dans la salle.',
        'ORA-20032': '⏱️ Alerte : La durée d\'accès a dépassé 4 heures.',
        'ORA-00001': '📧 Cet email ou ce numéro de téléphone est déjà utilisé.',
    }
    
    # Chercher le code dans l'erreur (avec ou sans le préfixe ORA-)
    for code, message in error_messages.items():
        if code in error_str or code.replace('ORA-', '') in error_str:
            # Extraire le message personnalisé si disponible
            if 'ORA-' in error_str:
                # Chercher le message après le code d'erreur
                import re
                pattern = r'ORA-\d+:\s*(.+)'
                match = re.search(pattern, error_str)
                if match:
                    return f'{message} {match.group(1)}'
            return message
    
    # Erreur inconnue - extraire le message Oracle si possible
    import re
    pattern = r'ORA-\d+:\s*(.+)'
    match = re.search(pattern, error_str)
    if match:
        return f'❌ Erreur Oracle: {match.group(1)[:150]}'
    
    # Erreur inconnue - afficher version tronquée
    return f'❌ Erreur technique: {error_str[:200]}...'

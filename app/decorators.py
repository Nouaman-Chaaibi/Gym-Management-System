from functools import wraps
from flask import redirect, url_for, flash
from flask_login import current_user, login_required


def role_required(role):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.is_authenticated:
                return login_required(lambda: None)()
            user_role = getattr(current_user, 'role', None)
            if user_role != role:
                flash('Accès refusé : privilèges insuffisants.', 'danger')
                return redirect(url_for('public.index'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator

"""
Script pour générer le hash bcrypt correct pour 'password123'
et mettre à jour les users dans la base de données
"""
import bcrypt

# Générer le hash pour "password123"
password = "password123"
password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

print("=" * 60)
print("HASH BCRYPT POUR 'password123':")
print("=" * 60)
print(password_hash)
print()
print("=" * 60)
print("SCRIPT SQL DE MISE À JOUR:")
print("=" * 60)
print(f"""
-- Mettre à jour tous les utilisateurs avec le bon hash
UPDATE auth_users SET password_hash = '{password_hash}';
COMMIT;

-- Vérifier
SELECT user_id, username, role FROM auth_users;
""")
print()
print("Copiez le script SQL ci-dessus et exécutez-le dans SQL*Plus ou SQL Developer")

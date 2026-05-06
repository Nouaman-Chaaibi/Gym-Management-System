-- Vérifier les triggers auto-increment
SELECT trigger_name, table_name, status, trigger_type
FROM user_triggers
WHERE trigger_name IN (
    'TRG_BEFORE_INSERT_MEMBRES',
    'TRG_BEFORE_INSERT_COACHS',
    'TRG_BEFORE_INSERT_ABONNEMENTS',
    'TRG_BEFORE_INSERT_SOUSCRIPTIONS',
    'TRG_BEFORE_INSERT_ACCES'
)
ORDER BY table_name;

-- Vérifier les contraintes UNIQUE sur MEMBRES  
SELECT constraint_name, constraint_type, column_name
FROM user_cons_columns
WHERE table_name = 'MEMBRES'
  AND constraint_name LIKE 'SYS_C%'
ORDER BY constraint_name;

-- Vérifier les membres existants avec leurs user_id
SELECT membre_id, nom, prenom, email, user_id
FROM membres
ORDER BY membre_id DESC
FETCH FIRST 10 ROWS ONLY;

-- Vérifier les users existants
SELECT user_id, username, role
FROM auth_users
ORDER BY user_id DESC
FETCH FIRST 10 ROWS ONLY;

-- Vérifier s'il y a des user_id dupliqués dans membres
SELECT user_id, COUNT(*) as count
FROM membres
GROUP BY user_id
HAVING COUNT(*) > 1;

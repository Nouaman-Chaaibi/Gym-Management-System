-- Vérifier l'état actuel des séquences
SELECT sequence_name, last_number, increment_by
FROM user_sequences
WHERE sequence_name IN (
    'SEQ_AUTH_USERS',
    'SEQ_MEMBRES',
    'SEQ_COACHS',
    'SEQ_ABONNEMENTS',
    'SEQ_SOUSCRIPTIONS',
    'SEQ_ACCES',
    'SEQ_SESSIONS',
    'SEQ_PAIEMENTS'
)
ORDER BY sequence_name;

-- Vérifier le max actuel dans chaque table
SELECT 'AUTH_USERS' as table_name, MAX(user_id) as max_id FROM auth_users
UNION ALL
SELECT 'MEMBRES', MAX(membre_id) FROM membres
UNION ALL
SELECT 'COACHS', MAX(coach_id) FROM coachs
UNION ALL
SELECT 'ABONNEMENTS', MAX(abonnement_id) FROM abonnements
UNION ALL
SELECT 'SOUSCRIPTIONS', MAX(souscription_id) FROM souscriptions
UNION ALL
SELECT 'ACCES', MAX(acces_id) FROM acces
UNION ALL
SELECT 'SESSIONS', MAX(session_id) FROM sessions
UNION ALL
SELECT 'PAIEMENTS', MAX(paiement_id) FROM paiements;

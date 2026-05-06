-- ============================================
-- RESYNCHRONISATION DES SÉQUENCES
-- Ce script ajuste les séquences pour éviter les conflits
-- ============================================

-- 1. SEQ_AUTH_USERS: max=9, on passe à 10
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(user_id), 0) INTO v_max FROM auth_users;
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_auth_users';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_auth_users START WITH ' || (v_max + 1) || ' INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE('SEQ_AUTH_USERS resynchronisée à ' || (v_max + 1));
END;
/

-- 2. SEQ_MEMBRES: max=5, on passe à 6
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(membre_id), 0) INTO v_max FROM membres;
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_membres';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_membres START WITH ' || (v_max + 1) || ' INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE('SEQ_MEMBRES resynchronisée à ' || (v_max + 1));
END;
/

-- 3. SEQ_COACHS: max=3, on passe à 4
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(coach_id), 0) INTO v_max FROM coachs;
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_coachs';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_coachs START WITH ' || (v_max + 1) || ' INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE('SEQ_COACHS resynchronisée à ' || (v_max + 1));
END;
/

-- 4. SEQ_ABONNEMENTS: max=3, on passe à 4
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(abonnement_id), 0) INTO v_max FROM abonnements;
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_abonnements';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_abonnements START WITH ' || (v_max + 1) || ' INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE('SEQ_ABONNEMENTS resynchronisée à ' || (v_max + 1));
END;
/

-- 5. SEQ_SOUSCRIPTIONS: max=4, on passe à 5
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(souscription_id), 0) INTO v_max FROM souscriptions;
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_souscriptions';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_souscriptions START WITH ' || (v_max + 1) || ' INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE('SEQ_SOUSCRIPTIONS resynchronisée à ' || (v_max + 1));
END;
/

-- 6. SEQ_ACCES: max=6, on passe à 7
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(acces_id), 0) INTO v_max FROM acces;
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_acces';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_acces START WITH ' || (v_max + 1) || ' INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE('SEQ_ACCES resynchronisée à ' || (v_max + 1));
END;
/

-- 7. SEQ_SESSIONS: max=3, on passe à 4
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(session_id), 0) INTO v_max FROM sessions;
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_sessions';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_sessions START WITH ' || (v_max + 1) || ' INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE('SEQ_SESSIONS resynchronisée à ' || (v_max + 1));
END;
/

-- 8. SEQ_PAIEMENTS: max=4, on passe à 5
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(paiement_id), 0) INTO v_max FROM paiements;
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_paiements';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_paiements START WITH ' || (v_max + 1) || ' INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE('SEQ_PAIEMENTS resynchronisée à ' || (v_max + 1));
END;
/

COMMIT;

-- Vérification
SELECT 'Vérification après resync:' as message FROM DUAL;

SELECT sequence_name, last_number
FROM user_sequences
WHERE sequence_name IN (
    'SEQ_AUTH_USERS', 'SEQ_MEMBRES', 'SEQ_COACHS', 
    'SEQ_ABONNEMENTS', 'SEQ_SOUSCRIPTIONS', 'SEQ_ACCES',
    'SEQ_SESSIONS', 'SEQ_PAIEMENTS'
)
ORDER BY sequence_name;

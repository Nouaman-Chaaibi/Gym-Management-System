-- ============================================
-- Trigger Auto-Increment pour AUTH_USERS
-- Génère automatiquement user_id si NULL
-- CRITIQUE: Résout ORA-01400 lors de l'inscription
-- ============================================

CREATE OR REPLACE TRIGGER trg_before_insert_auth_users
BEFORE INSERT ON auth_users
FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL THEN
        SELECT seq_auth_users.NEXTVAL INTO :NEW.user_id FROM DUAL;
    END IF;
END;
/

-- Message de confirmation
BEGIN
    DBMS_OUTPUT.PUT_LINE('Trigger trg_before_insert_auth_users créé avec succès.');
    DBMS_OUTPUT.PUT_LINE('  -> Auto-génère user_id lors de l''inscription');
END;
/

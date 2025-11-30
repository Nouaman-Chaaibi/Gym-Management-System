-- ============================================
-- Trigger Auto-Increment pour SESSIONS
-- Génère automatiquement session_id si NULL
-- ============================================

CREATE OR REPLACE TRIGGER trg_before_insert_session_id
BEFORE INSERT ON sessions
FOR EACH ROW
BEGIN
    IF :NEW.session_id IS NULL THEN
        SELECT seq_sessions.NEXTVAL INTO :NEW.session_id FROM DUAL;
    END IF;
END;
/

-- ============================================
-- Trigger Validation Âge Minimum (16 ans)
-- Vérifie l'âge AVANT insert/update sur MEMBRES
-- ============================================

CREATE OR REPLACE TRIGGER trg_check_age_membre
BEFORE INSERT OR UPDATE ON membres
FOR EACH ROW
DECLARE
    v_age NUMBER;
    v_date_limite DATE;
BEGIN
    -- Calculer la date limite (aujourd'hui - 16 ans)
    v_date_limite := ADD_MONTHS(SYSDATE, -16 * 12);
    
    -- Vérifier que la date de naissance n'est pas NULL
    IF :NEW.date_naissance IS NULL THEN
        RAISE_APPLICATION_ERROR(-20099, 'La date de naissance est obligatoire.');
    END IF;
    
    -- Vérifier que la date est dans le passé
    IF :NEW.date_naissance >= TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20100, 'La date de naissance doit être dans le passé, pas dans le futur.');
    END IF;
    
    -- Vérifier l'âge minimum (16 ans)
    IF :NEW.date_naissance > v_date_limite THEN
        -- Calculer l'âge exact
        v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, :NEW.date_naissance) / 12);
        RAISE_APPLICATION_ERROR(-20101, 'Vous devez avoir au moins 16 ans pour vous inscrire. Âge actuel: ' || v_age || ' ans.');
    END IF;
END;
/

-- ============================================
-- Messages de confirmation
-- ============================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Triggers créés avec succès:');
    DBMS_OUTPUT.PUT_LINE('  - trg_before_insert_session_id (auto-increment session_id)');
    DBMS_OUTPUT.PUT_LINE('  - trg_check_age_membre (validation âge >= 16 ans)');
END;
/

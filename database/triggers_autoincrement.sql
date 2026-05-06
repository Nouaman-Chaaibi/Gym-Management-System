-- ============================================
-- TRIGGER: Auto-increment membre_id
-- ============================================

CREATE OR REPLACE TRIGGER trg_before_insert_membres
BEFORE INSERT ON membres
FOR EACH ROW
BEGIN
    IF :NEW.membre_id IS NULL THEN
        SELECT seq_membres.NEXTVAL INTO :NEW.membre_id FROM DUAL;
    END IF;
END;
/

-- ============================================
-- TRIGGER: Auto-increment coach_id
-- ============================================

CREATE OR REPLACE TRIGGER trg_before_insert_coachs
BEFORE INSERT ON coachs
FOR EACH ROW
BEGIN
    IF :NEW.coach_id IS NULL THEN
        SELECT seq_coachs.NEXTVAL INTO :NEW.coach_id FROM DUAL;
    END IF;
END;
/

-- ============================================
-- TRIGGER: Auto-increment abonnement_id
-- ============================================

CREATE OR REPLACE TRIGGER trg_before_insert_abonnements
BEFORE INSERT ON abonnements
FOR EACH ROW
BEGIN
    IF :NEW.abonnement_id IS NULL THEN
        SELECT seq_abonnements.NEXTVAL INTO :NEW.abonnement_id FROM DUAL;
    END IF;
END;
/

-- ============================================
-- TRIGGER: Auto-increment souscription_id
-- ============================================

CREATE OR REPLACE TRIGGER trg_before_insert_souscriptions
BEFORE INSERT ON souscriptions
FOR EACH ROW
BEGIN
    IF :NEW.souscription_id IS NULL THEN
        SELECT seq_souscriptions.NEXTVAL INTO :NEW.souscription_id FROM DUAL;
    END IF;
END;
/

-- ============================================
-- TRIGGER: Auto-increment acces_id
-- ============================================

CREATE OR REPLACE TRIGGER trg_before_insert_acces
BEFORE INSERT ON acces
FOR EACH ROW
BEGIN
    IF :NEW.acces_id IS NULL THEN
        SELECT seq_acces.NEXTVAL INTO :NEW.acces_id FROM DUAL;
    END IF;
END;
/

COMMIT;

-- ============================================
-- Trigger Auto-Increment pour PAIEMENTS
-- Génère automatiquement paiement_id si NULL
-- ============================================

CREATE OR REPLACE TRIGGER trg_before_insert_paiement
BEFORE INSERT ON paiements
FOR EACH ROW
BEGIN
    IF :NEW.paiement_id IS NULL THEN
        SELECT seq_paiements.NEXTVAL INTO :NEW.paiement_id FROM DUAL;
    END IF;
END;
/

-- Message de confirmation
BEGIN
    DBMS_OUTPUT.PUT_LINE('Trigger trg_before_insert_paiement créé avec succès.');
END;
/

-- Avant insertion souscription : vérifier abonnement actif
CREATE OR REPLACE TRIGGER trg_before_insert_souscription
BEFORE INSERT ON souscriptions
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM souscriptions
  WHERE membre_id = :NEW.membre_id AND statut = 'ACTIF';

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20011, 'Membre a déjà un abonnement actif');
  END IF;
END;
/

-- Avant insertion accès : vérifier abonnement valide
CREATE OR REPLACE TRIGGER trg_before_insert_acces
BEFORE INSERT ON acces
FOR EACH ROW
BEGIN
  IF NOT func_verifier_abonnement_valide(:NEW.membre_id) THEN
    RAISE_APPLICATION_ERROR(-20012, 'Abonnement invalide pour l’accès');
  END IF;
END;
/

-- Avant insertion session : vérification coach et membre
CREATE OR REPLACE TRIGGER trg_before_insert_session
BEFORE INSERT ON sessions
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- Vérifier abonnement valide du membre
    IF NOT func_verifier_abonnement_valide(:NEW.membre_id) THEN
        RAISE_APPLICATION_ERROR(-20010, 'Le membre n''a pas d''abonnement valide');
    END IF;

    -- Vérifier disponibilité du coach
    IF NOT func_verifier_disponibilite_coach(:NEW.coach_id, :NEW.date_heure_debut, :NEW.date_heure_fin) THEN
        RAISE_APPLICATION_ERROR(-20011, 'Coach indisponible pour ce créneau');
    END IF;

    -- Vérifier conflit horaire du membre
    SELECT COUNT(*) INTO v_count
    FROM sessions
    WHERE membre_id = :NEW.membre_id
      AND ((date_heure_debut < :NEW.date_heure_fin AND date_heure_fin > :NEW.date_heure_debut));

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Conflit horaire pour le membre');
    END IF;

END;
/


-- Avant suppression coach : empêcher si sessions futures
CREATE OR REPLACE TRIGGER trg_before_delete_coach
BEFORE DELETE ON coachs
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM sessions
  WHERE coach_id = :OLD.coach_id AND date_heure_debut > SYSTIMESTAMP;

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20015, 'Coach a des sessions à venir');
  END IF;
END;
/

-- Après insertion paiement : passer souscription à ACTIF
CREATE OR REPLACE TRIGGER trg_after_insert_paiement
AFTER INSERT ON paiements
FOR EACH ROW
BEGIN
  UPDATE souscriptions SET statut = 'ACTIF' WHERE souscription_id = :NEW.souscription_id;
END;
/

-- Audit modification membre
CREATE OR REPLACE TRIGGER trg_after_update_membre
AFTER UPDATE ON membres
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('Membre '||:OLD.membre_id||' modifié : email='||:NEW.email||' statut='||:NEW.statut);
END;
/

-- Notification session
CREATE OR REPLACE TRIGGER trg_after_insert_session
AFTER INSERT ON sessions
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('Nouvelle session réservée: Membre='||:NEW.membre_id||' Coach='||:NEW.coach_id);
END;
/

-- Log accès
CREATE OR REPLACE TRIGGER trg_after_insert_acces
AFTER INSERT ON acces
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('Accès enregistré: Membre='||:NEW.membre_id||' Heure='||:NEW.date_heure_entree);
END;
/

CREATE OR REPLACE TRIGGER trg_before_insert_session_id
BEFORE INSERT ON sessions
FOR EACH ROW
BEGIN
    IF :NEW.session_id IS NULL THEN
        SELECT seq_sessions.NEXTVAL INTO :NEW.session_id FROM DUAL;
    END IF;
END;
/
-- 2. Validation âge 16 ans
CREATE OR REPLACE TRIGGER TRG_CHECK_AGE_MEMBRE
BEFORE INSERT OR UPDATE ON membres
FOR EACH ROW
DECLARE
    v_age NUMBER;
    v_date_limite DATE;
BEGIN
    -- Vérifier que la date de naissance est fournie
    IF :NEW.date_naissance IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le membre doit avoir au moins 16 ans pour s''inscrire. La date de naissance est obligatoire.');
    END IF;
    
    -- Vérifier que la date n'est pas dans le futur
    IF :NEW.date_naissance >= TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le membre doit avoir au moins 16 ans pour s''inscrire. La date de naissance doit être dans le passé.');
    END IF;
    
    -- Calculer la date limite (16 ans en arrière)
    v_date_limite := ADD_MONTHS(SYSDATE, -16 * 12);
    
    -- Vérifier l'âge minimum de 16 ans
    IF :NEW.date_naissance > v_date_limite THEN
        v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, :NEW.date_naissance) / 12);
        RAISE_APPLICATION_ERROR(-20001, 'Le membre doit avoir au moins 16 ans pour s''inscrire. Âge actuel: ' || v_age || ' ans.');
    END IF;
END;
/
COMMIT;

CREATE OR REPLACE TRIGGER trg_before_insert_auth_users
BEFORE INSERT ON auth_users
FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL THEN
        SELECT seq_auth_users.NEXTVAL INTO :NEW.user_id FROM DUAL;
    END IF;
END;
/

COMMIT;
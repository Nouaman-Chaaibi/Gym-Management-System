-- ============================================
-- MODIFICATIONS CRITIQUES - GYM MANAGEMENT
-- Exécuter dans SQL*Plus ou SQL Developer
-- ============================================

SET SERVEROUTPUT ON;

-- ============================================
-- 1. TRIGGER: Validation Âge Minimum (16 ans)
-- ============================================

CREATE OR REPLACE TRIGGER TRG_CHECK_AGE_MEMBRE
BEFORE INSERT OR UPDATE ON membres
FOR EACH ROW
DECLARE
    v_age NUMBER;
BEGIN
    -- Vérifier que la date de naissance n'est pas NULL
    IF :NEW.date_naissance IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'La date de naissance est obligatoire.');
    END IF;
    
    -- Vérifier que la date est dans le passé
    IF :NEW.date_naissance >= TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20002, 'La date de naissance doit être dans le passé, pas dans le futur.');
    END IF;
    
    -- Calculer l'âge exact
    v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, :NEW.date_naissance) / 12);
    
    -- Vérifier l'âge minimum (16 ans)
    IF v_age < 16 THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Le membre doit avoir au moins 16 ans pour s''inscrire. Âge actuel: ' || v_age || ' ans.');
    END IF;
END;
/

-- ============================================
-- 2. TRIGGER: Validation Horaires Ouverture Salle (6h-23h)
-- ============================================

CREATE OR REPLACE TRIGGER TRG_CHECK_HORAIRES_OUVERTURE
BEFORE INSERT ON acces
FOR EACH ROW
DECLARE
    v_heure NUMBER;
BEGIN
    v_heure := EXTRACT(HOUR FROM :NEW.date_heure_entree);
    
    IF v_heure < 6 OR v_heure >= 23 THEN
        RAISE_APPLICATION_ERROR(-20021, 
            'La salle est fermée. Horaires d''ouverture: 6h-23h. Votre tentative: ' || v_heure || 'h');
    END IF;
END;
/

-- ============================================
-- 3. PROCÉDURE: Modification Membre (Complète)
-- ============================================

CREATE OR REPLACE PROCEDURE proc_modifier_membre(
    p_membre_id NUMBER,
    p_nom VARCHAR2,
    p_prenom VARCHAR2,
    p_telephone VARCHAR2,
    p_adresse VARCHAR2,
    p_date_naissance DATE
) IS
BEGIN
    UPDATE membres
    SET nom = p_nom,
        prenom = p_prenom,
        telephone = p_telephone,
        adresse = p_adresse,
        date_naissance = p_date_naissance
    WHERE membre_id = p_membre_id;
    
    -- Le trigger TRG_CHECK_AGE_MEMBRE validera automatiquement l'âge
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'Membre non trouvé avec ID: ' || p_membre_id);
    END IF;
    
    COMMIT;
END;
/

-- ============================================
-- 4. PROCÉDURE: Modification Coach
-- ============================================

CREATE OR REPLACE PROCEDURE proc_modifier_coach(
    p_coach_id NUMBER,
    p_nom VARCHAR2,
    p_prenom VARCHAR2,
    p_telephone VARCHAR2,
    p_specialites VARCHAR2,
    p_tarif_horaire NUMBER
) IS
BEGIN
    UPDATE coachs
    SET nom = p_nom,
        prenom = p_prenom,
        telephone = p_telephone,
        specialites = p_specialites,
        tarif_horaire = p_tarif_horaire
    WHERE coach_id = p_coach_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20031, 'Coach non trouvé avec ID: ' || p_coach_id);
    END IF;
    
    COMMIT;
END;
/

-- ============================================
-- VÉRIFICATION - Afficher tous les triggers créés
-- ============================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('✅ TRIGGERS CRÉÉS/MIS À JOUR:');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════');
END;
/

SELECT trigger_name, table_name, status 
FROM user_triggers 
WHERE trigger_name IN (
    'TRG_CHECK_AGE_MEMBRE',
    'TRG_CHECK_HORAIRES_OUVERTURE'
)
ORDER BY trigger_name;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('✅ PROCÉDURES CRÉÉES/MISES À JOUR:');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════');
END;
/

SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_name IN (
    'PROC_MODIFIER_MEMBRE',
    'PROC_MODIFIER_COACH'
)
ORDER BY object_name;

-- ============================================
-- TESTS UNITAIRES
-- ============================================

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('🧪 TESTS UNITAIRES');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════');
END;
/

-- Test 1: Trigger âge minimum
DECLARE
    v_error VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 1: Insertion membre < 16 ans...');
    BEGIN
        INSERT INTO membres (membre_id, nom, prenom, date_naissance, email, telephone, statut, user_id)
        VALUES (999, 'Test', 'Mineur', TO_DATE('2015-01-01', 'YYYY-MM-DD'), 'test@test.com', '+212600000000', 'ACTIF', 999);
        DBMS_OUTPUT.PUT_LINE('❌ ÉCHEC: Insertion autorisée alors qu''elle devrait être refusée');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20001 THEN
                DBMS_OUTPUT.PUT_LINE('✅ SUCCESS: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('⚠️ Erreur inattendue: ' || SQLERRM);
            END IF;
            ROLLBACK;
    END;
END;
/

-- Test 2: Trigger date future
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 2: Insertion date future...');
    BEGIN
        INSERT INTO membres (membre_id, nom, prenom, date_naissance, email, telephone, statut, user_id)
        VALUES (999, 'Test', 'Futur', TO_DATE('2030-01-01', 'YYYY-MM-DD'), 'test2@test.com', '+212600000001', 'ACTIF', 999);
        DBMS_OUTPUT.PUT_LINE('❌ ÉCHEC: Date future acceptée');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20002 THEN
                DBMS_OUTPUT.PUT_LINE('✅ SUCCESS: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('⚠️ Erreur inattendue: ' || SQLERRM);
            END IF;
            ROLLBACK;
    END;
END;
/

-- Test 3: Insertion valide (20 ans)
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 3: Insertion membre valide (20 ans)...');
    BEGIN
        INSERT INTO membres (membre_id, nom, prenom, date_naissance, email, telephone, statut, user_id)
        VALUES (999, 'Test', 'Valide', TO_DATE('2004-01-01', 'YYYY-MM-DD'), 'test3@test.com', '+212600000002', 'ACTIF', NULL);
        DBMS_OUTPUT.PUT_LINE('✅ SUCCESS: Membre valide inséré');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ ÉCHEC: ' || SQLERRM);
            ROLLBACK;
    END;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('✅ SCRIPT TERMINÉ AVEC SUCCÈS');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('⚠️  IMPORTANT: Redémarrez Flask pour recharger les procédures');
    DBMS_OUTPUT.PUT_LINE('   Commande: Ctrl+C puis python run.py');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════');
END;
/

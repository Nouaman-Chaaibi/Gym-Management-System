-- ============================================
-- Script de Nettoyage des Données
-- Supprime toutes les données et réinitialise les séquences
-- ============================================

-- Désactiver temporairement les contraintes FK
BEGIN
    FOR c IN (SELECT constraint_name, table_name FROM user_constraints 
              WHERE constraint_type = 'R' AND owner = 'ADMIN_GYM') LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || 
                         ' DISABLE CONSTRAINT ' || c.constraint_name;
    END LOOP;
END;
/

-- Supprimer toutes les données (ordre: enfants → parents)
DELETE FROM acces;
DELETE FROM sessions;
DELETE FROM paiements;
DELETE FROM souscriptions;
DELETE FROM coachs;
DELETE FROM membres;
DELETE FROM abonnements;
DELETE FROM auth_users;

COMMIT;

-- Réinitialiser toutes les séquences
DROP SEQUENCE seq_acces;
DROP SEQUENCE seq_sessions;
DROP SEQUENCE seq_paiements;
DROP SEQUENCE seq_souscriptions;
DROP SEQUENCE seq_coachs;
DROP SEQUENCE seq_membres;
DROP SEQUENCE seq_abonnements;
DROP SEQUENCE seq_auth_users;

-- Recréer les séquences
CREATE SEQUENCE seq_auth_users START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_membres START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_coachs START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_abonnements START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_souscriptions START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_paiements START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_sessions START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_acces START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Réactiver les contraintes FK
BEGIN
    FOR c IN (SELECT constraint_name, table_name FROM user_constraints 
              WHERE constraint_type = 'R' AND owner = 'ADMIN_GYM') LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || 
                         ' ENABLE CONSTRAINT ' || c.constraint_name;
    END LOOP;
END;
/

COMMIT;

-- Message de confirmation
BEGIN
    DBMS_OUTPUT.PUT_LINE('Nettoyage terminé. Toutes les données ont été supprimées et les séquences réinitialisées.');
END;
/

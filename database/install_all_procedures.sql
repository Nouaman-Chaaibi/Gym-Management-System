-- ============================================
-- Script d'installation de toutes les procédures
-- Exécutez ce script avec SQL*Plus ou SQL Developer
-- en tant qu'utilisateur ADMIN_GYM
-- ============================================

-- Vérifier et installer les procédures depuis procedures.sql
@procedures.sql

-- Vérifier et installer les fonctions depuis fonctions.sql  
@fonctions.sql

-- Vérifier que les procédures critiques existent
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PROCEDURE', 'FUNCTION')
  AND object_name IN (
    'PROC_ENREGISTRER_SORTIE',
    'PROC_TERMINER_ACCES',
    'PROC_ENREGISTRER_ACCES',
    'PROC_INSCRIRE_MEMBRE',
    'PROC_MODIFIER_MEMBRE'
  )
ORDER BY object_name;

-- Afficher les erreurs de compilation s'il y en a
SELECT name, type, line, position, text
FROM user_errors
WHERE type IN ('PROCEDURE', 'FUNCTION')
ORDER BY name, sequence;

PROMPT '============================================';
PROMPT 'Installation terminée!';
PROMPT 'Vérifiez ci-dessus que toutes les procédures';
PROMPT 'ont le STATUS = VALID';
PROMPT '============================================';

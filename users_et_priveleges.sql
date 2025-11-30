-- ============================================
-- 1. Création des utilisateurs
-- ============================================

-- ADMIN_GYM : super-admin de l'application
CREATE USER admin_gym IDENTIFIED BY Admin123;
GRANT CONNECT, RESOURCE TO admin_gym;
-- Permission pour créer tables, séquences, procédures, vues, triggers
GRANT CREATE TABLE, CREATE SEQUENCE, CREATE PROCEDURE, CREATE VIEW, CREATE TRIGGER TO admin_gym;
ALTER USER ADMIN_GYM QUOTA UNLIMITED ON USERS;


-- COACH_GYM : accès limité, lecture/écriture sur ses sessions
CREATE USER coach_gym IDENTIFIED BY Coach123;
GRANT CONNECT TO coach_gym;

-- MEMBRE_GYM : accès limité, lecture sur son profil et réservation
CREATE USER membre_gym IDENTIFIED BY Membre123;
GRANT CONNECT TO membre_gym;


-- ============================================
-- 2. Explication rapide
-- ============================================

-- ADMIN_GYM :
-- Peut créer et modifier toutes les tables, séquences, procédures, fonctions, triggers, vues
-- Représente l'utilisateur principal pour le développement et la gestion des données

-- COACH_GYM :
-- Peut se connecter à la base et accéder aux objets via grants supplémentaires (à ajouter plus tard)
-- Les privilèges de lecture/écriture sur sessions et vues spécifiques seront ajoutés après création des objets

-- MEMBRE_GYM :
-- Peut se connecter à la base et accéder à ses propres données via des vues/procédures
-- Les privilèges supplémentaires (réservation, paiement, accès) seront définis après création des objets




-- =========================================================
-- 3. Privilèges sur les tables
-- =========================================================

-- ADMIN_GYM : tous droits sur ses tables (déjà propriétaire)
-- COACH_GYM : SELECT sur MEMBRES et ses SESSIONS, UPDATE sur SESSIONS (notes, statut)
GRANT SELECT ON admin_gym.membres TO coach_gym;
GRANT SELECT, UPDATE ON admin_gym.sessions TO coach_gym;

-- MEMBRE_GYM : SELECT sur ses propres souscriptions et sessions via vues
GRANT SELECT ON admin_gym.souscriptions TO membre_gym;
GRANT SELECT ON admin_gym.sessions TO membre_gym;
GRANT SELECT ON admin_gym.acces TO membre_gym;

-- =========================================================
-- 4. Privilèges sur les procédures et fonctions
-- =========================================================

-- ADMIN_GYM : tous droits sur ses procédures/fonctions (propriétaire)

-- COACH_GYM : EXECUTE sur procédures liées à ses actions
GRANT EXECUTE ON admin_gym.proc_reserver_session_coach TO coach_gym;
GRANT EXECUTE ON admin_gym.proc_confirmer_session TO coach_gym;
GRANT EXECUTE ON admin_gym.proc_annuler_session TO coach_gym;
GRANT EXECUTE ON admin_gym.func_verifier_disponibilite_coach TO coach_gym;

-- MEMBRE_GYM : EXECUTE sur procédures liées à son profil, réservation, accès
GRANT EXECUTE ON admin_gym.proc_inscrire_membre TO membre_gym;
GRANT EXECUTE ON admin_gym.proc_reserver_session_coach TO membre_gym;
GRANT EXECUTE ON admin_gym.proc_annuler_session TO membre_gym;
GRANT EXECUTE ON admin_gym.proc_enregistrer_acces TO membre_gym;
GRANT EXECUTE ON admin_gym.proc_terminer_acces TO membre_gym;
GRANT EXECUTE ON admin_gym.func_verifier_abonnement_valide TO membre_gym;
GRANT EXECUTE ON admin_gym.func_compter_sessions_membre TO membre_gym;
GRANT EXECUTE ON admin_gym.func_prochain_paiement TO membre_gym;

-- =========================================================
-- 5. Privilèges supplémentaires (vues / séquences)
-- =========================================================

-- ADMIN_GYM possède tout
-- COACH_GYM peut SELECT sur séquences si nécessaire
GRANT SELECT ON admin_gym.seq_sessions TO coach_gym;

-- MEMBRE_GYM peut SELECT sur séquences si nécessaire pour affichage
GRANT SELECT ON admin_gym.seq_souscriptions TO membre_gym;
GRANT SELECT ON admin_gym.seq_acces TO membre_gym;

-- =========================================================
-- 6. Remarques importantes
-- =========================================================
-- 1. Les triggers s'exécutent automatiquement avec les privilèges du propriétaire, donc pas besoin de GRANT spécifique.
-- 2. Les INSERT/UPDATE/DELETE directs sur les tables sont interdits pour COACH_GYM et MEMBRE_GYM, l'accès se fait uniquement via procédures/fonctions.
-- 3. Des vues spécifiques peuvent être créées pour restreindre l'affichage des données aux membres (ex: vw_mes_souscriptions, vw_mes_sessions).


-- ===========================
-- GRANT POUR LES VUES
-- ===========================

-- Admin : tous les droits (lecture, modification si nécessaire)
-- Admin : accès complet sur toutes les vues
GRANT SELECT, INSERT, UPDATE, DELETE ON vw_admin_membres TO admin_gym;
GRANT SELECT, INSERT, UPDATE, DELETE ON vw_admin_souscriptions TO admin_gym;
GRANT SELECT, INSERT, UPDATE, DELETE ON vw_admin_paiements TO admin_gym;
GRANT SELECT, INSERT, UPDATE, DELETE ON vw_admin_sessions TO admin_gym;
GRANT SELECT, INSERT, UPDATE, DELETE ON vw_admin_acces TO admin_gym;
GRANT SELECT ON vw_admin_revenus TO admin_gym;


-- Coach : lecture et modification limitée à ses sessions et membres associés
-- Coach : uniquement lecture sur ses sessions et membres
GRANT SELECT ON vw_coach_sessions TO coach_gym;
GRANT SELECT ON vw_coach_membres TO coach_gym;


-- Membre : lecture limitée à son profil et ses réservations/accès
-- Membre : uniquement lecture sur son profil et ses données
GRANT SELECT ON vw_membre_profil TO membre_gym;
GRANT SELECT ON vw_mes_souscriptions TO membre_gym;
GRANT SELECT ON vw_mes_sessions TO membre_gym;
GRANT SELECT ON vw_mes_acces TO membre_gym;


-- ===========================
-- NOTE
-- Les vues doivent exister avant d'exécuter ces GRANT
-- Admin_gym peut créer ou modifier les vues
-- Coach et Membre ne peuvent voir que ce qui les concerne
-- ===========================


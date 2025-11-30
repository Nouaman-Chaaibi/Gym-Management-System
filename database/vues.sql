-- =========================================================
-- 1️⃣ Vues pour les Membres
-- =========================================================

-- Vue des informations personnelles du membre
CREATE OR REPLACE VIEW vw_membre_profil AS
SELECT membre_id, nom, prenom, date_naissance, email, telephone, adresse, date_inscription, statut
FROM admin_gym.membres;

-- Vue des souscriptions du membre
CREATE OR REPLACE VIEW vw_mes_souscriptions AS
SELECT s.souscription_id, s.abonnement_id, a.nom AS nom_abonnement,
       s.date_debut, s.date_fin, s.statut, s.sessions_restantes
FROM admin_gym.souscriptions s
JOIN admin_gym.abonnements a ON s.abonnement_id = a.abonnement_id;

-- Vue des sessions réservées du membre
CREATE OR REPLACE VIEW vw_mes_sessions AS
SELECT se.session_id, se.date_heure_debut, se.date_heure_fin, se.type_session,
       se.statut, se.notes, c.nom AS nom_coach, c.prenom AS prenom_coach
FROM admin_gym.sessions se
JOIN admin_gym.coachs c ON se.coach_id = c.coach_id;

-- Vue des accès du membre
CREATE OR REPLACE VIEW vw_mes_acces AS
SELECT acces_id, date_heure_entree, date_heure_sortie, statut_acces, motif_refus
FROM admin_gym.acces;

-- =========================================================
-- 2️⃣ Vues pour les Coachs
-- =========================================================

-- Vue des sessions du coach
CREATE OR REPLACE VIEW vw_coach_sessions AS
SELECT se.session_id, se.membre_id, m.nom AS nom_membre, m.prenom AS prenom_membre,
       se.date_heure_debut, se.date_heure_fin, se.type_session, se.statut, se.notes
FROM admin_gym.sessions se
JOIN admin_gym.membres m ON se.membre_id = m.membre_id;

-- Vue des membres coachés
CREATE OR REPLACE VIEW vw_coach_membres AS
SELECT DISTINCT m.membre_id, m.nom, m.prenom, m.email, m.telephone, m.statut
FROM admin_gym.sessions se
JOIN admin_gym.membres m ON se.membre_id = m.membre_id
WHERE se.coach_id = SYS_CONTEXT('USERENV','SESSION_USER'); -- si possible adapter selon coach_id

-- =========================================================
-- 3️⃣ Vues pour les Administrateurs
-- =========================================================

-- Vue de tous les membres
CREATE OR REPLACE VIEW vw_admin_membres AS
SELECT * FROM admin_gym.membres;

-- Vue de toutes les souscriptions
CREATE OR REPLACE VIEW vw_admin_souscriptions AS
SELECT s.*, a.nom AS nom_abonnement, a.prix
FROM admin_gym.souscriptions s
JOIN admin_gym.abonnements a ON s.abonnement_id = a.abonnement_id;

-- Vue de tous les paiements
CREATE OR REPLACE VIEW vw_admin_paiements AS
SELECT p.*, s.membre_id, a.nom AS nom_abonnement
FROM admin_gym.paiements p
JOIN admin_gym.souscriptions s ON p.souscription_id = s.souscription_id
JOIN admin_gym.abonnements a ON s.abonnement_id = a.abonnement_id;

-- Vue de toutes les sessions
CREATE OR REPLACE VIEW vw_admin_sessions AS
SELECT se.*, m.nom AS nom_membre, m.prenom AS prenom_membre, 
       c.nom AS nom_coach, c.prenom AS prenom_coach
FROM admin_gym.sessions se
JOIN admin_gym.membres m ON se.membre_id = m.membre_id
JOIN admin_gym.coachs c ON se.coach_id = c.coach_id;

-- Vue de tous les accès
CREATE OR REPLACE VIEW vw_admin_acces AS
SELECT a.*, m.nom AS nom_membre, m.prenom AS prenom_membre
FROM admin_gym.acces a
JOIN admin_gym.membres m ON a.membre_id = m.membre_id;

-- Vue des revenus par période
CREATE OR REPLACE VIEW vw_admin_revenus AS
SELECT s.abonnement_id, a.nom AS nom_abonnement, SUM(p.montant) AS total_revenus
FROM admin_gym.paiements p
JOIN admin_gym.souscriptions s ON p.souscription_id = s.souscription_id
JOIN admin_gym.abonnements a ON s.abonnement_id = a.abonnement_id
WHERE p.statut_paiement = 'VALIDE'
GROUP BY s.abonnement_id, a.nom;

-- =========================================================
-- 4️⃣ Conseils de sécurité
-- =========================================================
-- 1. Chaque vue peut être accordée aux rôles spécifiques via GRANT SELECT.
-- 2. Pour les membres, il est recommandé d’ajouter un filtre WHERE pour qu’ils voient uniquement leurs données,
--    par exemple : WHERE membre_id = SYS_CONTEXT('USERENV','SESSION_USER') si vous mappez le user_id.
-- 3. Les coachs ne doivent voir que leurs sessions et membres coachés.
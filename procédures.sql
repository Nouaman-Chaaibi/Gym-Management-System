-- ============================================
-- Membres
-- ============================================

-- Inscription d'un membre
CREATE OR REPLACE PROCEDURE proc_inscrire_membre(
    p_nom VARCHAR2, p_prenom VARCHAR2,
    p_date_naissance DATE,
    p_email VARCHAR2, p_telephone VARCHAR2,
    p_adresse VARCHAR2
) IS
  v_user_id NUMBER;
  v_count NUMBER;
BEGIN
  IF MONTHS_BETWEEN(SYSDATE, p_date_naissance) < 192 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Membre doit avoir au moins 16 ans');
  END IF;

  -- Vérifier email unique
  SELECT COUNT(*) INTO v_count
  FROM membres
  WHERE email = p_email;

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Email déjà utilisé');
  END IF;

  -- Création utilisateur AUTH_USERS
  INSERT INTO auth_users(user_id, username, password_hash, role, date_creation, actif)
  VALUES (seq_auth_users.NEXTVAL, p_email, 'password_demo', 'MEMBRE', SYSDATE, 'O')
  RETURNING user_id INTO v_user_id;

  -- Création membre
  INSERT INTO membres(membre_id, nom, prenom, date_naissance, email, telephone, adresse, date_inscription, statut, user_id)
  VALUES (seq_membres.NEXTVAL, p_nom, p_prenom, p_date_naissance, p_email, p_telephone, p_adresse, SYSDATE, 'ACTIF', v_user_id);

  COMMIT;
END;
/


-- Modifier infos membre
CREATE OR REPLACE PROCEDURE proc_modifier_membre(
    p_membre_id NUMBER,
    p_adresse VARCHAR2,
    p_telephone VARCHAR2,
    p_statut VARCHAR2
) IS
BEGIN
  UPDATE membres
  SET adresse = p_adresse,
      telephone = p_telephone,
      statut = p_statut
  WHERE membre_id = p_membre_id;

  COMMIT;
END;
/

-- Désactiver membre
CREATE OR REPLACE PROCEDURE proc_desactiver_membre(p_membre_id NUMBER) IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM souscriptions
  WHERE membre_id = p_membre_id AND statut = 'ACTIF';

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Membre a une souscription active');
  END IF;

  UPDATE membres SET statut = 'SUSPENDU' WHERE membre_id = p_membre_id;

  COMMIT;
END;
/


-- ============================================
-- Abonnements & Souscriptions
-- ============================================

-- Souscrire un abonnement
CREATE OR REPLACE PROCEDURE proc_souscrire_abonnement(
    p_membre_id NUMBER,
    p_abonnement_id NUMBER
) IS
BEGIN
  INSERT INTO souscriptions(souscription_id, membre_id, abonnement_id, date_debut, date_fin, statut, date_souscription, sessions_restantes)
  VALUES (seq_souscriptions.NEXTVAL, p_membre_id, p_abonnement_id,
          SYSDATE,
          ADD_MONTHS(SYSDATE, (SELECT duree_mois FROM abonnements WHERE abonnement_id = p_abonnement_id)),
          'EN_ATTENTE',
          SYSDATE,
          (SELECT nombre_sessions_incluses FROM abonnements WHERE abonnement_id = p_abonnement_id));
  COMMIT;
END;
/

-- Renouveler abonnement
CREATE OR REPLACE PROCEDURE proc_renouveler_abonnement(p_souscription_id NUMBER) IS
  v_duree NUMBER;
BEGIN
  SELECT a.duree_mois INTO v_duree
  FROM souscriptions s JOIN abonnements a ON s.abonnement_id = a.abonnement_id
  WHERE souscription_id = p_souscription_id;

  UPDATE souscriptions
  SET date_debut = SYSDATE,
      date_fin = ADD_MONTHS(SYSDATE, v_duree),
      sessions_restantes = (SELECT nombre_sessions_incluses FROM abonnements WHERE abonnement_id = (SELECT abonnement_id FROM souscriptions WHERE souscription_id = p_souscription_id)),
      statut = 'ACTIF'
  WHERE souscription_id = p_souscription_id;

  COMMIT;
END;
/

-- Annuler souscription
CREATE OR REPLACE PROCEDURE proc_annuler_souscription(p_souscription_id NUMBER) IS
BEGIN
  UPDATE souscriptions SET statut = 'ANNULE' WHERE souscription_id = p_souscription_id;

  -- Simulation remboursement : mettre les paiements en REFUSE
  UPDATE paiements SET statut_paiement = 'REFUSE' WHERE souscription_id = p_souscription_id;

  COMMIT;
END;
/


-- ============================================
-- Paiements
-- ============================================

-- Enregistrer paiement
CREATE OR REPLACE PROCEDURE proc_enregistrer_paiement(
    p_souscription_id NUMBER,
    p_montant NUMBER,
    p_methode VARCHAR2,
    p_reference VARCHAR2
) IS
  v_statut VARCHAR2(20);
  v_prix NUMBER;
BEGIN
  SELECT statut INTO v_statut FROM souscriptions WHERE souscription_id = p_souscription_id;
  SELECT prix INTO v_prix FROM abonnements WHERE abonnement_id = (SELECT abonnement_id FROM souscriptions WHERE souscription_id = p_souscription_id);

  IF v_statut != 'EN_ATTENTE' THEN
    RAISE_APPLICATION_ERROR(-20004, 'Souscription non en attente de paiement');
  END IF;

  IF p_montant != v_prix THEN
    RAISE_APPLICATION_ERROR(-20005, 'Montant incorrect');
  END IF;

  INSERT INTO paiements(paiement_id, souscription_id, montant, date_paiement, methode_paiement, statut_paiement, reference)
  VALUES (seq_paiements.NEXTVAL, p_souscription_id, p_montant, SYSDATE, p_methode, 'VALIDE', p_reference);

  UPDATE souscriptions SET statut = 'ACTIF' WHERE souscription_id = p_souscription_id;

  COMMIT;
END;
/

-- Annuler paiement
CREATE OR REPLACE PROCEDURE proc_annuler_paiement(p_paiement_id NUMBER) IS
  v_souscription_id NUMBER;
  v_count NUMBER;
BEGIN
  -- Récupérer la souscription
  SELECT souscription_id INTO v_souscription_id
  FROM paiements
  WHERE paiement_id = p_paiement_id;

  -- Annuler le paiement
  UPDATE paiements
  SET statut_paiement = 'REFUSE'
  WHERE paiement_id = p_paiement_id;

  -- Vérifier s'il reste des paiements valides
  SELECT COUNT(*) INTO v_count
  FROM paiements
  WHERE souscription_id = v_souscription_id
    AND statut_paiement = 'VALIDE';

  IF v_count = 0 THEN
    UPDATE souscriptions
    SET statut = 'EN_ATTENTE'
    WHERE souscription_id = v_souscription_id;
  END IF;

  COMMIT;
END;
/



-- ============================================
-- Sessions coaching
-- ============================================

-- Réserver session
CREATE OR REPLACE PROCEDURE proc_reserver_session_coach(
    p_membre_id NUMBER,
    p_coach_id NUMBER,
    p_date_debut TIMESTAMP,
    p_date_fin TIMESTAMP,
    p_type_session VARCHAR2
) IS
  v_count NUMBER;
BEGIN
  IF NOT func_verifier_abonnement_valide(p_membre_id) THEN
    RAISE_APPLICATION_ERROR(-20006, 'Abonnement invalide');
  END IF;

  IF NOT func_verifier_disponibilite_coach(p_coach_id, p_date_debut, p_date_fin) THEN
    RAISE_APPLICATION_ERROR(-20007, 'Coach indisponible');
  END IF;

  -- Vérifier conflit horaire membre
  SELECT COUNT(*) INTO v_count
  FROM sessions
  WHERE membre_id = p_membre_id
    AND ((date_heure_debut < p_date_fin AND date_heure_fin > p_date_debut));

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20008, 'Conflit horaire pour le membre');
  END IF;

  INSERT INTO sessions(session_id, membre_id, coach_id, date_heure_debut, date_heure_fin, type_session, statut, date_reservation)
  VALUES (seq_sessions.NEXTVAL, p_membre_id, p_coach_id, p_date_debut, p_date_fin, p_type_session, 'RESERVEE', SYSDATE);

  COMMIT;
END;
/


-- Annuler session
CREATE OR REPLACE PROCEDURE proc_annuler_session(p_session_id NUMBER) IS
  v_date_debut TIMESTAMP;
  v_membre_id NUMBER;
BEGIN
  SELECT date_heure_debut, membre_id INTO v_date_debut, v_membre_id FROM sessions WHERE session_id = p_session_id;

  IF v_date_debut - INTERVAL '12' HOUR <= SYSTIMESTAMP THEN
    RAISE_APPLICATION_ERROR(-20009, 'Annulation interdite moins de 12h avant la session');
  END IF;

  UPDATE sessions SET statut = 'ANNULEE' WHERE session_id = p_session_id;

  -- Remise à jour sessions restantes
  UPDATE souscriptions
  SET sessions_restantes = sessions_restantes + 1
  WHERE membre_id = v_membre_id AND statut = 'ACTIF';

  COMMIT;
END;
/

-- Confirmer session
CREATE OR REPLACE PROCEDURE proc_confirmer_session(p_session_id NUMBER) IS
BEGIN
  UPDATE sessions SET statut = 'CONFIRMEE' WHERE session_id = p_session_id;
  COMMIT;
END;
/


-- ============================================
-- Accès / Check-in
-- ============================================

-- Enregistrer accès
CREATE OR REPLACE PROCEDURE proc_enregistrer_acces(p_membre_id NUMBER) IS
BEGIN
  IF NOT func_verifier_abonnement_valide(p_membre_id) THEN
    RAISE_APPLICATION_ERROR(-20010, 'Abonnement invalide');
  END IF;

  INSERT INTO acces(acces_id, membre_id, date_heure_entree, statut_acces)
  VALUES (seq_acces.NEXTVAL, p_membre_id, SYSTIMESTAMP, 'EN_COURS');

  COMMIT;
END;
/

-- Terminer accès
CREATE OR REPLACE PROCEDURE proc_terminer_acces(p_acces_id NUMBER) IS
BEGIN
  UPDATE acces
  SET date_heure_sortie = SYSTIMESTAMP,
      statut_acces = 'TERMINE'
  WHERE acces_id = p_acces_id;

  COMMIT;
END;
/


-- ============================================
-- Statistiques
-- ============================================

-- Statistiques membre
CREATE OR REPLACE PROCEDURE proc_generer_statistiques_membre(p_membre_id NUMBER) IS
  v_sessions NUMBER;
  v_payments NUMBER;
BEGIN
  v_sessions := func_compter_sessions_membre(p_membre_id);
  SELECT COUNT(*) INTO v_payments FROM paiements p JOIN souscriptions s ON p.souscription_id = s.souscription_id WHERE s.membre_id = p_membre_id AND p.statut_paiement='VALIDE';

  DBMS_OUTPUT.PUT_LINE('Membre ID: ' || p_membre_id);
  DBMS_OUTPUT.PUT_LINE('Nombre de sessions: ' || v_sessions);
  DBMS_OUTPUT.PUT_LINE('Nombre de paiements validés: ' || v_payments);
END;
/

-- Revenus période
CREATE OR REPLACE PROCEDURE proc_generer_revenus_periode(p_date_debut DATE, p_date_fin DATE) IS
  v_total NUMBER;
BEGIN
  v_total := func_calculer_revenus_total(p_date_debut, p_date_fin);
  DBMS_OUTPUT.PUT_LINE('Revenus entre ' || p_date_debut || ' et ' || p_date_fin || ': ' || v_total);
END;
/

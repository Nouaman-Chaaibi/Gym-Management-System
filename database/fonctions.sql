-- Vérifie si un membre a un abonnement valide
CREATE OR REPLACE FUNCTION func_verifier_abonnement_valide(p_membre_id NUMBER) RETURN BOOLEAN IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM souscriptions
  WHERE membre_id = p_membre_id
    AND statut = 'ACTIF'
    AND date_fin >= SYSDATE;

  RETURN v_count > 0;
END;
/

-- Calcule la date de fin d'une souscription
CREATE OR REPLACE FUNCTION func_calculer_date_expiration(p_souscription_id NUMBER) RETURN DATE IS
  v_date_debut DATE;
  v_duree NUMBER;
BEGIN
  SELECT date_debut, a.duree_mois INTO v_date_debut, v_duree
  FROM souscriptions s
       JOIN abonnements a ON s.abonnement_id = a.abonnement_id
  WHERE souscription_id = p_souscription_id;

  RETURN ADD_MONTHS(v_date_debut, v_duree);
END;
/

-- Compte le nombre de sessions pour un membre
CREATE OR REPLACE FUNCTION func_compter_sessions_membre(p_membre_id NUMBER) RETURN NUMBER IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM sessions
  WHERE membre_id = p_membre_id;

  RETURN v_count;
END;
/

-- Vérifie la disponibilité d'un coach pour un créneau donné
CREATE OR REPLACE FUNCTION func_verifier_disponibilite_coach(
    p_coach_id NUMBER,
    p_date_debut TIMESTAMP,
    p_date_fin TIMESTAMP
) RETURN BOOLEAN IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM sessions
  WHERE coach_id = p_coach_id
    AND ((date_heure_debut < p_date_fin AND date_heure_fin > p_date_debut));

  RETURN v_count = 0;
END;
/

-- Retourne la date du prochain paiement pour un membre
CREATE OR REPLACE FUNCTION func_prochain_paiement(p_membre_id NUMBER) RETURN DATE IS
  v_date DATE;
BEGIN
  SELECT MIN(date_fin) INTO v_date
  FROM souscriptions
  WHERE membre_id = p_membre_id
    AND statut = 'ACTIF';
  RETURN v_date;
END;
/

-- Total des paiements validés (optionnel : période)
CREATE OR REPLACE FUNCTION func_calculer_revenus_total(p_date_debut DATE DEFAULT NULL, p_date_fin DATE DEFAULT NULL) RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  IF p_date_debut IS NULL THEN
    SELECT NVL(SUM(montant),0) INTO v_total
    FROM paiements
    WHERE statut_paiement = 'VALIDE';
  ELSE
    SELECT NVL(SUM(montant),0) INTO v_total
    FROM paiements
    WHERE statut_paiement = 'VALIDE'
      AND date_paiement BETWEEN p_date_debut AND p_date_fin;
  END IF;
  RETURN v_total;
END;
/

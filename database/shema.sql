-- ============================================
-- Création des Tables pour ADMIN_GYM
-- ============================================

-- 1. Table AUTH_USERS
CREATE TABLE auth_users (
    user_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    password_hash VARCHAR2(200) NOT NULL,
    role VARCHAR2(20) NOT NULL,
    date_creation DATE DEFAULT CURRENT_DATE NOT NULL,
    dernier_login TIMESTAMP NULL,
    actif CHAR(1) DEFAULT 'O' NOT NULL,
    CONSTRAINT ck_auth_role CHECK (role IN ('ADMIN','COACH','MEMBRE')),
    CONSTRAINT ck_auth_actif CHECK (actif IN ('O','N'))
);

-- 2. Table MEMBRES
CREATE TABLE membres (
    membre_id NUMBER PRIMARY KEY,
    nom VARCHAR2(50) NOT NULL,
    prenom VARCHAR2(50) NOT NULL,
    date_naissance DATE NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    telephone VARCHAR2(20) NOT NULL,
    adresse VARCHAR2(200),
    date_inscription DATE DEFAULT CURRENT_DATE NOT NULL,
    statut VARCHAR2(20) DEFAULT 'ACTIF' NOT NULL,
    user_id NUMBER NOT NULL UNIQUE,
    CONSTRAINT ck_membres_statut CHECK (statut IN ('ACTIF','SUSPENDU','INACTIF'))
);

-- 3. Table COACHS
CREATE TABLE coachs (
    coach_id NUMBER PRIMARY KEY,
    nom VARCHAR2(50) NOT NULL,
    prenom VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    telephone VARCHAR2(20) NOT NULL,
    specialites VARCHAR2(200) NOT NULL,
    salaire_horaire NUMBER(10,2) NOT NULL,
    date_embauche DATE DEFAULT CURRENT_DATE NOT NULL,
    actif CHAR(1) DEFAULT 'O' NOT NULL,
    user_id NUMBER NOT NULL UNIQUE,
    CONSTRAINT ck_coachs_actif CHECK (actif IN ('O','N')),
    CONSTRAINT ck_coachs_salaire CHECK (salaire_horaire > 0)
);

-- 4. Table ABONNEMENTS
CREATE TABLE abonnements (
    abonnement_id NUMBER PRIMARY KEY,
    nom VARCHAR2(50) NOT NULL UNIQUE,
    description VARCHAR2(200),
    duree_mois NUMBER NOT NULL,
    prix NUMBER(10,2) NOT NULL,
    type_abonnement VARCHAR2(20) NOT NULL,
    nombre_sessions_incluses NUMBER DEFAULT 0,
    date_creation DATE DEFAULT CURRENT_DATE NOT NULL,
    actif CHAR(1) DEFAULT 'O' NOT NULL,
    CONSTRAINT ck_abonnements_duree CHECK (duree_mois >= 1),
    CONSTRAINT ck_abonnements_prix CHECK (prix > 0),
    CONSTRAINT ck_abonnements_type CHECK (type_abonnement IN ('BASIC','PREMIUM','VIP')),
    CONSTRAINT ck_abonnements_actif CHECK (actif IN ('O','N'))
);

-- 5. Table SOUSCRIPTIONS
CREATE TABLE souscriptions (
    souscription_id NUMBER PRIMARY KEY,
    membre_id NUMBER NOT NULL,
    abonnement_id NUMBER NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    statut VARCHAR2(20) DEFAULT 'EN_ATTENTE' NOT NULL,
    date_souscription DATE DEFAULT CURRENT_DATE NOT NULL,
    sessions_restantes NUMBER DEFAULT 0,
    CONSTRAINT fk_souscriptions_membre FOREIGN KEY (membre_id) REFERENCES membres(membre_id),
    CONSTRAINT fk_souscriptions_abonnement FOREIGN KEY (abonnement_id) REFERENCES abonnements(abonnement_id),
    CONSTRAINT ck_souscriptions_statut CHECK (statut IN ('EN_ATTENTE','ACTIF','EXPIRE','ANNULE')),
    CONSTRAINT ck_souscriptions_dates CHECK (date_fin > date_debut),
    CONSTRAINT ck_souscriptions_sessions CHECK (sessions_restantes >= 0)
);

-- 6. Table PAIEMENTS
CREATE TABLE paiements (
    paiement_id NUMBER PRIMARY KEY,
    souscription_id NUMBER NOT NULL,
    montant NUMBER(10,2) NOT NULL,
    date_paiement DATE DEFAULT CURRENT_DATE NOT NULL,
    methode_paiement VARCHAR2(20) NOT NULL,
    statut_paiement VARCHAR2(20) DEFAULT 'VALIDE' NOT NULL,
    reference VARCHAR2(50) UNIQUE,
    CONSTRAINT fk_paiements_souscription FOREIGN KEY (souscription_id) REFERENCES souscriptions(souscription_id),
    CONSTRAINT ck_paiements_montant CHECK (montant > 0),
    CONSTRAINT ck_paiements_methode CHECK (methode_paiement IN ('ESPECES','CARTE','VIREMENT')),
    CONSTRAINT ck_paiements_statut CHECK (statut_paiement IN ('VALIDE','REFUSE','EN_ATTENTE'))
);

-- 7. Table SESSIONS
CREATE TABLE sessions (
    session_id NUMBER PRIMARY KEY,
    membre_id NUMBER NOT NULL,
    coach_id NUMBER NOT NULL,
    date_heure_debut TIMESTAMP NOT NULL,
    date_heure_fin TIMESTAMP NOT NULL,
    type_session VARCHAR2(50) NOT NULL,
    statut VARCHAR2(20) DEFAULT 'RESERVEE' NOT NULL,
    notes VARCHAR2(500),
    date_reservation DATE DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT fk_sessions_membre FOREIGN KEY (membre_id) REFERENCES membres(membre_id),
    CONSTRAINT fk_sessions_coach FOREIGN KEY (coach_id) REFERENCES coachs(coach_id),
    CONSTRAINT ck_sessions_duree CHECK (date_heure_fin > date_heure_debut),
    CONSTRAINT ck_sessions_statut CHECK (statut IN ('RESERVEE','CONFIRMEE','ANNULEE','TERMINEE'))
);

-- 8. Table ACCES
CREATE TABLE acces (
    acces_id NUMBER PRIMARY KEY,
    membre_id NUMBER NOT NULL,
    date_heure_entree TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    date_heure_sortie TIMESTAMP NULL,
    statut_acces VARCHAR2(20) DEFAULT 'EN_COURS' NOT NULL,
    motif_refus VARCHAR2(200),
    CONSTRAINT fk_acces_membre FOREIGN KEY (membre_id) REFERENCES membres(membre_id),
    CONSTRAINT ck_acces_statut CHECK (statut_acces IN ('EN_COURS','TERMINE','REFUSE')),
    CONSTRAINT ck_acces_sortie CHECK (date_heure_sortie IS NULL OR date_heure_sortie > date_heure_entree)
);

-- ============================================
-- Fin du script tables
-- ============================================


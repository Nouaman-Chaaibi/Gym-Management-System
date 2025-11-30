-- ============================================
-- Création des séquences pour AUTO-INCREMENT
-- ============================================

-- Séquence pour AUTH_USERS
CREATE SEQUENCE seq_auth_users
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Séquence pour MEMBRES
CREATE SEQUENCE seq_membres
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Séquence pour COACHS
CREATE SEQUENCE seq_coachs
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Séquence pour ABONNEMENTS
CREATE SEQUENCE seq_abonnements
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Séquence pour SOUSCRIPTIONS
CREATE SEQUENCE seq_souscriptions
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Séquence pour PAIEMENTS
CREATE SEQUENCE seq_paiements
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Séquence pour SESSIONS
CREATE SEQUENCE seq_sessions
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Séquence pour ACCES
CREATE SEQUENCE seq_acces
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- ============================================
-- Fin du script de séquences
-- ============================================

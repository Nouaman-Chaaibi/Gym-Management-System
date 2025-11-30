-- ============================================
-- Données de Test Cohérentes
-- ============================================

-- ========== AUTH_USERS ==========
-- Tous les mots de passe sont hashés avec bcrypt pour "password123"
-- Hash bcrypt: $2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u

-- Admin
INSERT INTO auth_users VALUES (1, 'admin@gym.ma', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u', 'ADMIN', SYSDATE, NULL, 'O');

-- Coachs (3)
INSERT INTO auth_users VALUES (2, 'karim.bennani@gym.ma', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u', 'COACH', SYSDATE, NULL, 'O');
INSERT INTO auth_users VALUES (3, 'sara.alaoui@gym.ma', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u', 'COACH', SYSDATE, NULL, 'O');
INSERT INTO auth_users VALUES (4, 'mehdi.tazi@gym.ma', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u', 'COACH', SYSDATE, NULL, 'O');

-- Membres (5)
INSERT INTO auth_users VALUES (5, 'ahmed.idrissi@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u', 'MEMBRE', SYSDATE, NULL, 'O');
INSERT INTO auth_users VALUES (6, 'fatima.benali@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u', 'MEMBRE', SYSDATE, NULL, 'O');
INSERT INTO auth_users VALUES (7, 'youssef.el-amrani@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u', 'MEMBRE', SYSDATE, NULL, 'O');
INSERT INTO auth_users VALUES (8, 'nadia.lakbir@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u', 'MEMBRE', SYSDATE, NULL, 'O');
INSERT INTO auth_users VALUES (9, 'omar.chraibi@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW3jvKqzPW8u', 'MEMBRE', SYSDATE, NULL, 'O');

-- ========== ABONNEMENTS ==========
INSERT INTO abonnements (
    abonnement_id, nom, description, duree_mois, prix, type_abonnement,
    nombre_sessions_incluses, date_creation, actif
) VALUES (
    1, 'BASIC', 'Accès illimité à la salle + casier personnel',
    1, 200, 'BASIC', 
    4, SYSDATE, 'O'
);
INSERT INTO abonnements (
    abonnement_id, nom, description, duree_mois, prix, type_abonnement,
    nombre_sessions_incluses, date_creation, actif
) VALUES (
    2,
    'PREMIUM',
    'BASIC + 12 sessions coaching/mois + espace wellness',
    3,
    500,
    'PREMIUM',
    12,
    SYSDATE,
    'O'
);
INSERT INTO abonnements (
    abonnement_id, nom, description, duree_mois, prix, type_abonnement,
    nombre_sessions_incluses, date_creation, actif
) VALUES (
    3,
    'VIP',
    'PREMIUM + coaching illimité + accès 24/7 + nutrition',
    12,
    1500,
    'VIP',
    999,
    SYSDATE,
    'O'
);

-- ========== COACHS ==========
INSERT INTO coachs VALUES (1, 'Bennani', 'Karim', 'karim.bennani@gym.ma', '+212600111222', 'Musculation, Force', 150, TO_DATE('2020-01-15', 'YYYY-MM-DD'), 'O', 2);
INSERT INTO coachs VALUES (2, 'Alaoui', 'Sara', 'sara.alaoui@gym.ma', '+212600222333', 'Cardio, Yoga, Pilates', 120, TO_DATE('2021-03-20', 'YYYY-MM-DD'), 'O', 3);
INSERT INTO coachs VALUES (3, 'Tazi', 'Mehdi', 'mehdi.tazi@gym.ma', '+212600333444', 'Nutrition, CrossFit, HIIT', 180, TO_DATE('2019-06-10', 'YYYY-MM-DD'), 'O', 4);

-- ========== MEMBRES ==========
INSERT INTO membres VALUES (1, 'Idrissi', 'Ahmed', TO_DATE('1990-05-12', 'YYYY-MM-DD'), 'ahmed.idrissi@gmail.com', '+212612345001', 'Casablanca, Maarif', SYSDATE, 'ACTIF', 5);
INSERT INTO membres VALUES (2, 'Benali', 'Fatima', TO_DATE('1995-08-22', 'YYYY-MM-DD'), 'fatima.benali@gmail.com', '+212612345002', 'Rabat, Agdal', SYSDATE, 'ACTIF', 6);
INSERT INTO membres VALUES (3, 'El Amrani', 'Youssef', TO_DATE('1988-11-30', 'YYYY-MM-DD'), 'youssef.el-amrani@gmail.com', '+212612345003', 'Casablanca, Ain Diab', SYSDATE - 90, 'INACTIF', 7);
INSERT INTO membres VALUES (4, 'Lakbir', 'Nadia', TO_DATE('1992-03-18', 'YYYY-MM-DD'), 'nadia.lakbir@gmail.com', '+212612345004', 'Marrakech, Gueliz', SYSDATE - 30, 'ACTIF', 8);
INSERT INTO membres VALUES (5, 'Chraibi', 'Omar', TO_DATE('1985-07-05', 'YYYY-MM-DD'), 'omar.chraibi@gmail.com', '+212612345005', 'Tanger, Centre-ville', SYSDATE - 120, 'SUSPENDU', 9);

-- ========== SOUSCRIPTIONS ==========
-- Membre 1: PREMIUM actif (3 mois)
INSERT INTO souscriptions VALUES (1, 1, 2, SYSDATE - 15, ADD_MONTHS(SYSDATE - 15, 3), 'ACTIF', SYSDATE - 15, 10);

-- Membre 2: BASIC actif (1 mois)
INSERT INTO souscriptions VALUES (2, 2, 1, SYSDATE - 5, ADD_MONTHS(SYSDATE - 5, 1), 'ACTIF', SYSDATE - 5, 3);

-- Membre 3: BASIC expiré
INSERT INTO souscriptions VALUES (3, 3, 1, SYSDATE - 90, SYSDATE - 60, 'EXPIRE', SYSDATE - 90, 0);

-- Membre 4: VIP actif (12 mois)
INSERT INTO souscriptions VALUES (4, 4, 3, SYSDATE - 30, ADD_MONTHS(SYSDATE - 30, 12), 'ACTIF', SYSDATE - 30, 999);

-- ========== PAIEMENTS ==========
-- Les paiement_id seront générés automatiquement par le trigger
INSERT INTO paiements (souscription_id, montant, date_paiement, methode_paiement, statut_paiement, reference)
VALUES (1, 500, SYSDATE - 15, 'CARTE', 'VALIDE', 'PAY-20251112001');

INSERT INTO paiements (souscription_id, montant, date_paiement, methode_paiement, statut_paiement, reference)
VALUES (2, 200, SYSDATE - 5, 'ESPECE', 'VALIDE', 'PAY-20251122001');

INSERT INTO paiements (souscription_id, montant, date_paiement, methode_paiement, statut_paiement, reference)
VALUES (3, 200, SYSDATE - 90, 'CARTE', 'VALIDE', 'PAY-20250828001');

INSERT INTO paiements (souscription_id, montant, date_paiement, methode_paiement, statut_paiement, reference)
VALUES (4, 1500, SYSDATE - 30, 'CARTE', 'VALIDE', 'PAY-20251028001');

-- ========== SESSIONS ==========
-- Sessions à venir (RESERVEE)
INSERT INTO sessions VALUES (1, 1, 1, SYSTIMESTAMP + INTERVAL '2' DAY, SYSTIMESTAMP + INTERVAL '2' DAY + INTERVAL '1' HOUR, 'Individuelle', 'RESERVEE', SYSDATE);
INSERT INTO sessions VALUES (2, 2, 2, SYSTIMESTAMP + INTERVAL '3' DAY, SYSTIMESTAMP + INTERVAL '3' DAY + INTERVAL '1' HOUR, 'Individuelle', 'RESERVEE', SYSDATE);
INSERT INTO sessions VALUES (3, 4, 3, SYSTIMESTAMP + INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '1' DAY + INTERVAL '1' HOUR, 'Individuelle', 'CONFIRMEE', SYSDATE - 1);

-- Sessions passées (TERMINEE)
INSERT INTO sessions VALUES (4, 1, 2, SYSTIMESTAMP - INTERVAL '5' DAY, SYSTIMESTAMP - INTERVAL '5' DAY + INTERVAL '1' HOUR, 'Groupe', 'TERMINEE', SYSDATE - 6);
INSERT INTO sessions VALUES (5, 2, 1, SYSTIMESTAMP - INTERVAL '10' DAY, SYSTIMESTAMP - INTERVAL '10' DAY + INTERVAL '1' HOUR, 'Individuelle', 'TERMINEE', SYSDATE - 11);

-- Session annulée
INSERT INTO sessions VALUES (6, 4, 1, SYSTIMESTAMP + INTERVAL '5' DAY, SYSTIMESTAMP + INTERVAL '5' DAY + INTERVAL '1' HOUR, 'Individuelle', 'ANNULEE', SYSDATE - 2);

-- ========== ACCES ==========
-- Accès terminés
INSERT INTO acces VALUES (1, 1, SYSTIMESTAMP - INTERVAL '2' DAY, SYSTIMESTAMP - INTERVAL '2' DAY + INTERVAL '2' HOUR, 'TERMINE');
INSERT INTO acces VALUES (2, 2, SYSTIMESTAMP - INTERVAL '3' DAY, SYSTIMESTAMP - INTERVAL '3' DAY + INTERVAL '1' HOUR + INTERVAL '30' MINUTE, 'TERMINE');
INSERT INTO acces VALUES (3, 4, SYSTIMESTAMP - INTERVAL '1' DAY, SYSTIMESTAMP - INTERVAL '1' DAY + INTERVAL '3' HOUR, 'TERMINE');

-- Accès en cours
INSERT INTO acces VALUES (4, 1, SYSTIMESTAMP - INTERVAL '30' MINUTE, NULL, 'EN_COURS');

COMMIT;

-- Message de confirmation
BEGIN
    DBMS_OUTPUT.PUT_LINE('Données de test insérées avec succès.');
    DBMS_OUTPUT.PUT_LINE('Utilisateurs créés:');
    DBMS_OUTPUT.PUT_LINE('  - Admin: admin@gym.ma (password: password123)');
    DBMS_OUTPUT.PUT_LINE('  - Coachs: karim.bennani@gym.ma, sara.alaoui@gym.ma, mehdi.tazi@gym.ma');
    DBMS_OUTPUT.PUT_LINE('  - Membres: ahmed.idrissi@gmail.com, fatima.benali@gmail.com, etc.');
    DBMS_OUTPUT.PUT_LINE('Tous les mots de passe: password123');
END;
/

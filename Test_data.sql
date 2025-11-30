------------------------------------------------------------
-- 1) AUTH_USERS  (1 admin, 2 coachs, 3 membres)
------------------------------------------------------------

INSERT INTO auth_users VALUES (
    seq_auth_users.NEXTVAL, 'admin1', 'HASH_ADMIN_123', 'ADMIN',
    SYSDATE, NULL, 'O'
);

INSERT INTO auth_users VALUES (
    seq_auth_users.NEXTVAL, 'coach_samir', 'HASH_COACH1', 'COACH',
    SYSDATE, NULL, 'O'
);

INSERT INTO auth_users VALUES (
    seq_auth_users.NEXTVAL, 'coach_sara', 'HASH_COACH2', 'COACH',
    SYSDATE, NULL, 'O'
);

INSERT INTO auth_users VALUES (
    seq_auth_users.NEXTVAL, 'member_amine', 'HASH_MEMBRE1', 'MEMBRE',
    SYSDATE, NULL, 'O'
);

INSERT INTO auth_users VALUES (
    seq_auth_users.NEXTVAL, 'member_hiba', 'HASH_MEMBRE2', 'MEMBRE',
    SYSDATE, NULL, 'O'
);

INSERT INTO auth_users VALUES (
    seq_auth_users.NEXTVAL, 'member_reda', 'HASH_MEMBRE3', 'MEMBRE',
    SYSDATE, NULL, 'O'
);


INSERT INTO auth_users (
    user_id, username, password_hash, role, date_creation, actif
) VALUES (
    17,
    'coach_karim',
    'HASH_COACH3',
    'COACH',
    SYSDATE,
    'O'
);




------------------------------------------------------------
-- 2) COACHS  (2 coachs)
-- user_id = 2, 3
------------------------------------------------------------

INSERT INTO coachs VALUES (
    seq_coachs.NEXTVAL, 'Samir', 'Benali', 'samir.benali@gym.com',
    '0612345678', 'Musculation, HIIT', 150,
    SYSDATE, 'O', 2
);

INSERT INTO coachs VALUES (
    seq_coachs.NEXTVAL, 'Sara', 'El Amrani', 'sara.elamrani@gym.com',
    '0623456789', 'Cardio, Perte de poids', 120,
    SYSDATE, 'O', 3
);


INSERT INTO coachs (
    coach_id, nom, prenom, email, telephone, specialites, salaire_horaire, date_embauche, actif, user_id
) VALUES (
    seq_coachs.NEXTVAL,
    'BENSAID', 
    'Karim', 
    'karim.bensaid@example.com', 
    '0600123456', 
    'Musculation, Cardio, Crossfit', 
    150.00, 
    TO_DATE('2023-09-01','YYYY-MM-DD'), 
    'O', 
    2
);



------------------------------------------------------------
-- 3) MEMBRES (3 membres)
-- user_id = 4, 5, 6
------------------------------------------------------------

INSERT INTO membres VALUES (
    seq_membres.NEXTVAL, 'Amine', 'Lahmidi', DATE '2000-03-15',
    'amine.lahmidi@gmail.com', '0654321890', 'Hay Riad, Rabat',
    SYSDATE, 'ACTIF', 4
);

INSERT INTO membres VALUES (
    seq_membres.NEXTVAL, 'Hiba', 'Chakir', DATE '1999-10-05',
    'hiba.chakir@gmail.com', '0678912345', 'Agdal, Rabat',
    SYSDATE, 'ACTIF', 5
);

INSERT INTO membres VALUES (
    seq_membres.NEXTVAL, 'Reda', 'Moujahid', DATE '1998-01-22',
    'reda.moujahid@gmail.com', '0667891234', 'Temara',
    SYSDATE, 'INACTIF', 6
);

------------------------------------------------------------
-- 4) ABONNEMENTS (3 types)
------------------------------------------------------------

INSERT INTO abonnements VALUES (
    seq_abonnements.NEXTVAL, 'Basic', 'Accès salle + 4 sessions', 
    1, 199, 'BASIC', 4, SYSDATE, 'O'
);

INSERT INTO abonnements VALUES (
    seq_abonnements.NEXTVAL, 'Premium', 'Accès complet + 10 sessions',
    3, 499, 'PREMIUM', 10, SYSDATE, 'O'
);

INSERT INTO abonnements VALUES (
    seq_abonnements.NEXTVAL, 'VIP', 'Accès illimité + 25 sessions',
    12, 1499, 'VIP', 25, SYSDATE, 'O'
);

------------------------------------------------------------
-- 5) SOUSCRIPTIONS (réalistes)
-- membre 1 → Premium
-- membre 2 → Basic
-- membre 3 → VIP expiré
------------------------------------------------------------

-- Amine (membre 1)
INSERT INTO souscriptions VALUES (
    seq_souscriptions.NEXTVAL, 13, 7,
    SYSDATE, ADD_MONTHS(SYSDATE, 3),
    'ACTIF', SYSDATE, 10
);

-- Hiba (membre 2)
INSERT INTO souscriptions VALUES (
    seq_souscriptions.NEXTVAL, 14, 6,
    SYSDATE, ADD_MONTHS(SYSDATE, 1),
    'ACTIF', SYSDATE, 4
);

-- Reda (membre 3) : expiré
INSERT INTO souscriptions VALUES (
    seq_souscriptions.NEXTVAL, 15, 8,
    ADD_MONTHS(SYSDATE, -12), SYSDATE - 200,
    'EXPIRE', ADD_MONTHS(SYSDATE, -12), 0
);

------------------------------------------------------------
-- 6) PAIEMENTS (réalistes)
------------------------------------------------------------

INSERT INTO paiements VALUES (
    seq_paiements.NEXTVAL, 8, 499, SYSDATE, 'CARTE', 'VALIDE', 'REF001'
);

INSERT INTO paiements VALUES (
    seq_paiements.NEXTVAL, 9, 199, SYSDATE, 'ESPECES', 'VALIDE', 'REF002'
);

INSERT INTO paiements VALUES (
    seq_paiements.NEXTVAL, 10, 1499, ADD_MONTHS(SYSDATE, -12),
    'VIREMENT', 'VALIDE', 'REF003'
);

------------------------------------------------------------
-- 7) SESSIONS (réalistes)
------------------------------------------------------------

-- Session confirmée Amine / Coach Samir
INSERT INTO sessions VALUES (
    seq_sessions.NEXTVAL, 13, 4,
    SYSTIMESTAMP + INTERVAL '1' DAY,
    SYSTIMESTAMP + INTERVAL '1' DAY + INTERVAL '1' HOUR,
    'Coaching Musculation', 'CONFIRMEE', NULL, SYSDATE
);

-- Session réservée Hiba / Coach Sara
INSERT INTO sessions VALUES (
    seq_sessions.NEXTVAL, 14, 5,
    SYSTIMESTAMP + INTERVAL '2' DAY,
    SYSTIMESTAMP + INTERVAL '2' DAY + INTERVAL '1' HOUR,
    'Cardio Training', 'RESERVEE', NULL, SYSDATE
);

-- Session Reda (devrait être refusée car abonnement expiré → test logique)
-- NOTE : si le trigger refuse, c’est normal
INSERT INTO sessions VALUES (
    seq_sessions.NEXTVAL, 15, 13,
    SYSTIMESTAMP + INTERVAL '3' DAY,
    SYSTIMESTAMP + INTERVAL '3' DAY + INTERVAL '2' HOUR,
    'Crossfit', 'ANNULEE', 'Abonnement expiré', SYSDATE
);

------------------------------------------------------------
-- 8) ACCES (réalistes)
------------------------------------------------------------

-- Amine → accès terminé
INSERT INTO acces VALUES (
    seq_acces.NEXTVAL, 13,
    SYSTIMESTAMP - INTERVAL '2' HOUR,
    SYSTIMESTAMP - INTERVAL '1' HOUR,
    'TERMINE', NULL
);

-- Hiba → accès en cours
INSERT INTO acces VALUES (
    seq_acces.NEXTVAL, 14,
    SYSTIMESTAMP - INTERVAL '1' HOUR,
    NULL,
    'EN_COURS', NULL
);

-- Reda → refusé (abonnement expiré)
INSERT INTO acces VALUES (
    seq_acces.NEXTVAL, 15,
    SYSTIMESTAMP, NULL,
    'REFUSE', 'Abonnement expiré'
);

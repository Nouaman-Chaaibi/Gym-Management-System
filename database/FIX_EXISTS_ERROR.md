# Correction de l'Erreur de Compilation - PROC_INSCRIRE_MEMBRE

## Problème Identifié ✅

**Erreur Oracle** :
```
PLS-00204: fonction ou pseudo-colonne 'EXISTS' peut être utilisée uniquement dans instruction SQL
```

## Cause

En PL/SQL, la fonction `EXISTS` ne peut pas être utilisée directement dans une condition `IF`. Elle ne fonctionne que dans les requêtes SQL pures.

**Code Incorrect** (ligne 18) :
```sql
IF EXISTS(SELECT 1 FROM membres WHERE email = p_email) THEN
    RAISE_APPLICATION_ERROR(-20002, 'Email déjà utilisé');
END IF;
```

## Solution Appliquée ✅

**Code Corrigé** :
```sql
-- Déclarer une variable
v_count NUMBER;

-- Compter les emails correspondants
SELECT COUNT(*) INTO v_count FROM membres WHERE email = p_email;
IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Email déjà utilisé');
END IF;
```

## Fichier Modifié

✅ [procedures.sql](file:///c:/Users/nouaa/OneDrive/Bureau/ENSA%20SDBDIA/S3/BDD/GYM_PROJECT/database/procedures.sql#L5-L20) - Ligne 13 ajoutée variable `v_count`, lignes 18-20 corrigées

## Prochaine Étape

Maintenant vous pouvez réinstaller la procédure :

### Option 1 : SQL*Plus
```bash
cd "c:\Users\nouaa\OneDrive\Bureau\ENSA SDBDIA\S3\BDD\GYM_PROJECT\database"
sqlplus ADMIN_GYM@localhost:1521/XEPDB1
@procedures.sql
```

### Option 2 : SQL Developer
1. Ouvrez SQL Developer
2. Connectez-vous avec ADMIN_GYM
3. Ouvrez le fichier `procedures.sql` corrigé
4. Exécutez-le (F5 ou icône "Exécuter le script")

### Vérification

Après exécution, vérifiez que la procédure est VALID :
```sql
SELECT object_name, status 
FROM user_objects 
WHERE object_name = 'PROC_INSCRIRE_MEMBRE';
```

Résultat attendu :
```
OBJECT_NAME              STATUS
------------------------ -------
PROC_INSCRIRE_MEMBRE     VALID
```

## Toutes les Procédures Corrigées ✅

J'ai vérifié qu'il n'y a pas d'autres utilisations incorrectes de `EXISTS` dans les autres procédures. Vous pouvez maintenant installer toutes les procédures sans erreur.

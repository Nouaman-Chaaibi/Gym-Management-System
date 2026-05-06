# 🔧 CORRECTION URGENTE - Triggers Auto-increment Manquants

## Problème Identifié

**Erreur** : `ORA-01400: impossible d'insérer NULL dans ("ADMIN_GYM"."MEMBRES"."MEMBRE_ID")`

**Cause** : Il n'y a pas de triggers pour auto-incrémenter les IDs (membre_id, coach_id, etc.) avec les séquences.

## Solution : Installer les Triggers

J'ai créé le fichier [triggers_autoincrement.sql](file:///c:/Users/nouaa/OneDrive/Bureau/ENSA%20SDBDIA/S3/BDD/GYM_PROJECT/database/triggers_autoincrement.sql) avec tous les triggers manquants.

### Installation

**Ouvrez SQL*Plus ou SQL Developer** et exécutez :

```bash
cd "c:\Users\nouaa\OneDrive\Bureau\ENSA SDBDIA\S3\BDD\GYM_PROJECT\database"
sqlplus ADMIN_GYM@localhost:1521/XEPDB1
@triggers_autoincrement.sql
```

OU dans SQL Developer :
1. Connectez-vous avec ADMIN_GYM
2. Ouvrez le fichier `triggers_autoincrement.sql`
3. Appuyez sur F5 (Exécuter le script)

### Triggers Créés

- ✅ `trg_before_insert_membres` - Auto-incrémente `membre_id`
- ✅ `trg_before_insert_coachs` - Auto-incrémente `coach_id`
- ✅ `trg_before_insert_abonnements` - Auto-incrémente `abonnement_id`
- ✅ `trg_before_insert_souscriptions` - Auto-incrémente `souscription_id`
- ✅ `trg_before_insert_acces` - Auto-incrémente `acces_id`

### Vérification

Après installation, vérifiez que les triggers existent :

```sql
SELECT trigger_name, table_name, status 
FROM user_triggers 
WHERE trigger_name LIKE 'TRG_BEFORE_INSERT%'
ORDER BY trigger_name;
```

Tous doivent avoir STATUS = 'ENABLED'.

## Test

Après installation :

1. Allez sur `/admin/membres/ajouter`
2. Remplissez le formulaire
3. ✅ Le membre devrait être créé avec succès !

Le `membre_id` sera automatiquement généré par le trigger.

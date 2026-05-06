# Instructions d'Installation des Procédures Oracle

## Problème Identifié
L'erreur `PLS-00201: l'identificateur 'PROC_ENREGISTRER_SORTIE' doit être déclaré` indique que les procédures stockées ne sont pas installées dans votre base de données Oracle.

## Solution : Installer les Procédures

### Option 1 : Utiliser SQL*Plus (Recommandé)

```bash
# Naviguez vers le dossier database
cd "c:\Users\nouaa\OneDrive\Bureau\ENSA SDBDIA\S3\BDD\GYM_PROJECT\database"

# Connectez-vous à Oracle avec l'utilisateur ADMIN_GYM
sqlplus ADMIN_GYM@localhost:1521/XEPDB1

# Entrez le mot de passe quand demandé
# Puis exécutez le script d'installation
@install_all_procedures.sql
```

### Option 2 : Utiliser SQL Developer

1. Ouvrez **Oracle SQL Developer**
2. Connectez-vous avec l'utilisateur `ADMIN_GYM`
3. Ouvrez le fichier `database/procedures.sql`
4. Cliquez sur **Exécuter le script** (icône avec un document et une flèche verte)
5. Puis ouvrez et exécutez `database/fonctions.sql`

### Option 3 : Exécuter les Fichiers Individuellement

```sql
-- Dans SQL*Plus ou SQL Developer, exécutez dans cet ordre :
@sequences.sql
@fonctions.sql
@procedures.sql
@triggers.sql
```

## Vérification

Après l'installation, vérifiez que les procédures existent :

```sql
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PROCEDURE', 'FUNCTION')
  AND object_name LIKE 'PROC_%'
ORDER BY object_name;
```

Toutes les procédures doivent avoir `STATUS = VALID`.

## Procédures Critiques Requises

- ✅ `PROC_ENREGISTRER_SORTIE` - Pour déclarer la sortie d'un membre
- ✅ `PROC_TERMINER_ACCES` - Appelée par proc_enregistrer_sortie
- ✅ `PROC_ENREGISTRER_ACCES` - Pour l'entrée d'un membre
- ✅ `PROC_INSCRIRE_MEMBRE` - Pour créer un nouveau membre
- ✅ `PROC_MODIFIER_MEMBRE` - Pour modifier un membre

## Problèmes Résolus

### 1. Date de Naissance ✅ RÉSOLU
- **Problème** : Impossible de sélectionner des dates anciennes
- **Solution** : Attribut `max` retiré du champ date dans `membre_form.html`
- **Résultat** : Vous pouvez maintenant sélectionner n'importe quelle date passée
- **Validation** : Le système vérifie toujours que l'âge >= 16 ans côté serveur

### 2. Contrôle d'Accès - Sortie ⏳ EN ATTENTE
- **Problème** : Erreur Oracle lors de la déclaration de sortie
- **Solution** : Installer les procédures stockées (instructions ci-dessus)
- **Résultat** : Après installation, vous pourrez déclarer les sorties des membres

## Test Après Installation

1. **Tester la sortie d'un membre** :
   - Allez sur `/admin/acces`
   - Cliquez sur "Sortie" pour un membre présent
   - ✅ Devrait afficher "Sortie enregistrée avec succès"

2. **Tester la date de naissance** :
   - Allez sur `/admin/membres/ajouter`
   - Sélectionnez une date de naissance (ex: 01/01/1990)
   - ✅ La date devrait être sélectionnable
   - ✅ Si l'âge < 16 ans, le serveur rejette avec un message d'erreur

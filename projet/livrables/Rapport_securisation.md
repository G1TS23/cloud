# Rapport de sécurisation — Projet DocBox (BC04)

> **Auteur :** Olivier Falahi · **Date :** _à compléter_ · **Compétence visée :** C25 (liens C21–C24)
> Document attendu en livrable, à côté de l'application déployée.

---

## 1. Contexte & périmètre

- **Application :** _nom, rôle, utilisateurs._
- **Données traitées & sensibilité :** _ex. documents et métadonnées → enjeu de confidentialité et d'intégrité (RGPD si données personnelles)._
- **Architecture (rappel) :** _services Azure utilisés : App Service, base (SQL/Cosmos), Storage Blob, Key Vault, App Insights._

## 2. Analyse de risques (avant sécurisation)

| Risque | Cause | Impact | Probabilité | Priorité |
|---|---|---|---|---|
| Secrets en clair (chaîne de connexion, clés) | Stockés dans le code/config | Compromission | Élevée | Haute |
| Accès non chiffré (HTTP) | TLS non forcé | Interception des données | Moyenne | Haute |
| Stockage / base exposés | Configuration publique | Fuite de documents | Moyenne | Haute |
| Droits trop larges | Owner/Contributor partout | Action non maîtrisée | Moyenne | Moyenne |
| Absence de traçabilité | Logs non collectés | Diagnostic / audit impossible | Moyenne | Moyenne |
| Accès non authentifié | Pas de contrôle d'accès applicatif | Données accessibles à tous | Moyenne | Haute |

## 3. Mesures de sécurité mises en œuvre

| Domaine | Mesure | Service / techno | Statut | Preuve |
|---|---|---|---|---|
| Chiffrement transport | **HTTPS only** + TLS 1.2 | App Service | ⬜ | capture |
| Gestion des secrets | **Azure Key Vault** (aucun secret en dur) | Key Vault + Managed Identity | ⬜ | capture |
| Identité & accès (plan Azure) | **RBAC moindre privilège** | Entra ID / RBAC | ⬜ | export rôles |
| Authentification applicative | _Auth utilisateur (Entra ID / login)_ | App Service Auth / Entra ID | ⬜ | capture |
| Réseau | **Accès restreint** (IP / private endpoint / NSG) | App Service access restrictions / NSG | ⬜ | capture |
| Données au repos | Chiffrement + **accès privé** | Storage / SQL | ⬜ | capture |
| Journalisation | Logs centralisés | App Insights / Activity Log | ⬜ | capture |

## 4. Conformité réglementaire

- **RGPD :** _données personnelles ? → minimisation, hébergement UE (région), chiffrement au repos et en transit, gestion des accès, suppression possible._
- **Confidentialité & intégrité :** chiffrement + contrôle d'accès strict + journalisation des actions.
- _Autres cadres applicables : à préciser._

## 5. Gestion des identités et des accès

- **Identité managée** pour l'app (elle accède à Key Vault / Storage **sans secret**).
- **RBAC** : rôles minimaux par ressource (ex. *Key Vault Secrets User*, *Storage Blob Data Contributor*) — pas d'Owner superflu.
- _Comptes nominatifs, séparation des droits, revue d'accès._

## 6. Tests de validation

| Test | Attendu | Résultat |
|---|---|---|
| Accès HTTP → redirigé HTTPS | Redirection 301/308 | ⬜ |
| Secret absent du code | `git grep` ne révèle aucun secret | ⬜ |
| Accès direct au Storage (sans droit) | Refusé (privé) | ⬜ |
| Accès à l'app sans authentification | Refusé / redirigé login | ⬜ |
| Lecture d'un secret via Managed Identity | Réussie (sans clé en dur) | ⬜ |

## 7. Risques résiduels & améliorations

- _Ex. WAF (Application Gateway / Front Door), Defender for Cloud, rotation automatique des secrets, déploiement multi-zone, tests de restauration, alertes de sécurité._

## 8. Synthèse

_Niveau de sécurité atteint, principaux acquis (HTTPS, Key Vault, identité managée, accès restreint, journalisation), et ce qu'il faudrait ajouter en contexte de production réelle._

# TP4 — Fiche d'audit Activity Log

> Source : Azure Activity Log du Resource Group `rg-shopeasy-dev`, désormais exporté vers le Log Analytics Workspace `law-shopeasy-dev` (diagnostic setting `diag-activitylog-shopeasy`). Extraction du 29/06/2026 via `az monitor activity-log list`.

## Contexte

L'Activity Log enregistre les opérations du plan de gestion Azure (créations, modifications, suppressions, changements de droits). Les opérations ci-dessous correspondent à la mise en place du dispositif d'exploitation du TP4 et servent de **preuves d'audit** réelles.

## Trois événements significatifs

| # | Horodatage (UTC) | Opération | Ressource | Statut | Interprétation |
|---|---|---|---|---|---|
| 1 | 2026-06-29 12:41 | Create Workspace | `law-shopeasy-dev` | Succeeded | Mise en place de l'**observabilité centralisée** : création du Log Analytics Workspace destiné à recevoir logs et métriques. Changement structurant, attendu et légitime. |
| 2 | 2026-06-29 12:43 | Create and update budgets | `budget-shopeasy-dev` | Succeeded | Mise en place du **garde-fou FinOps** : budget mensuel 50 € avec alertes 80 %/100 %. Trace la prise de contrôle des coûts. |
| 3 | 2026-06-29 12:41 | Create or update action group | `ag-shopeasy-ops` | Succeeded | Création du **canal de notification** des alertes (email équipe Ops). Pré-requis pour rendre les alertes actionnables. |

## Lecture d'audit

- **Cohérence :** les trois opérations sont des écritures réussies, réalisées par le même compte d'administration, dans une fenêtre de quelques minutes — cohérent avec une session d'exploitation planifiée.
- **Détection d'anomalie :** si l'une de ces opérations (par exemple une modification de règle NSG ou un changement RBAC) avait eu lieu hors fenêtre de maintenance ou par un compte inattendu, elle aurait dû déclencher l'alerte `alert-nsg-change-shopeasy` et faire l'objet d'une vérification.
- **Traçabilité durable :** l'export vers `law-shopeasy-dev` permet désormais des requêtes KQL et la conservation des événements au-delà des 90 jours de rétention native de l'Activity Log, condition d'un contrôle interne exploitable par la DSI.

## Réponses aux questions d'analyse (atelier 8)

1. **Importance de l'Activity Log :** il répond à « qui a fait quoi, quand » sur les ressources Azure, base de l'audit et du post-mortem.
2. **Log technique vs log d'activité :** le log technique provient de la ressource (OS, Nginx) ; le log d'activité provient du plan de gestion Azure (opérations ARM).
3. **Information parfois manquante :** la justification métier du changement et la corrélation avec les logs applicatifs.
4. **Exploitation DSI :** revues périodiques, requêtes KQL, alertes sur opérations sensibles, preuve de conformité.

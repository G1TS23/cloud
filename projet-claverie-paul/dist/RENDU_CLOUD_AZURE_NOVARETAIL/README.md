# Épreuve Cloud Azure — NovaRetail

Rendu anonymisé de l'épreuve finale pratique : migration et sécurisation de l'infrastructure NovaRetail sur Microsoft Azure.

## Contenu du dossier

| Élément | Rôle |
|---------|------|
| **`RAPPORT_FINAL.pdf`** | Livrable principal — réponses aux 6 parties (20 questions), diagnostic, captures, schémas, monitoring, FinOps, sécurité, note DSI, questions théoriques |
| **`infra/`** | Projet Terraform déployé (région `swedencentral`) — sans fichiers d'état ni secrets |
| **`schemas/`** | Schémas d'architecture cible et corrigée (PNG + sources Mermaid) |
| **`screenshots/`** | Captures Azure Portal complémentaires (lisibilité hors PDF) |

## Conformité au sujet (minimum requis, §1.1)

- Rapport final PDF
- Schémas d'architecture (PNG)
- Fichiers Terraform
- Diagnostic et corrections (dans le PDF)
- Captures de validation (dans le PDF + dossier `screenshots/`)
- Réponses théoriques et note DSI (dans le PDF)

Le script d'audit de tags (Partie 4) est **documenté dans le rapport** (pseudo-script avec entrées, sorties et limites) ; il n'est pas dupliqué en fichier séparé.

## Déploiement Terraform

```bash
cd infra
terraform init
terraform plan
terraform apply
# terraform destroy   # après validation — préserve le crédit Azure
```

Les mots de passe et clés SSH sont générés par Terraform (`tls` / `random`) et ne sont jamais versionnés.

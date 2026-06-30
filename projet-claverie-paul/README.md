# Épreuve finale pratique — Cloud Azure (Cas NovaRetail)

> **Auteur :** Paul Claverie · **Type :** épreuve individuelle, niveau Mastère · **Barème :** 20 points
> **Module :** Panorama du cloud et déploiement Azure — Bloc 4 « Optimisation du SI par l'apport du Cloud Computing »

Migration de l'application **NovaRetail** (serveur Linux unique on-premise) vers **Microsoft Azure** :
architecture cible, diagnostic d'une architecture défectueuse, déploiement Infrastructure as Code,
administration, monitoring, FinOps, sécurité et questions théoriques (dont traçabilité blockchain).

**L'infrastructure a été réellement déployée et validée** sur la souscription **Azure for Students**
(région `swedencentral`) via Terraform, puis détruite après capture des preuves.

---

## Organisation du dossier

```
projet-claverie-paul/
├── README.md                       # ce fichier
├── sujet/
│   ├── EPREUVE_CLOUD_AZURE.pdf      # énoncé officiel
│   └── EPREUVE_CLOUD_AZURE.md       # conversion fidèle du sujet en Markdown
├── rapport/                        # réponses détaillées, par partie
│   ├── partie1_architecture.md     # Q1 risques, Q2 services, Q3 schéma cible
│   ├── partie2_diagnostic.md       # Q4 anomalies, Q5 priorisation, Q6 archi corrigée, Q7 vérif
│   ├── partie3_terraform.md        # Q8-Q11 IaC + captures de validation
│   ├── partie4_administration.md   # Q12 inventaire, Q13 tags, Q14 script
│   ├── partie5_monitoring.md       # Q15 monitoring, Q16 FinOps, Q17 sécu, Q18 note DSI
│   └── partie6_theorique.md        # 20 questions (Cloud/Azure + blockchain)
├── infra/                          # code Terraform (déployé réellement)
│   ├── main.tf · variables.tf · outputs.tf · terraform.tfvars · README.md · .gitignore
├── scripts/
│   ├── azure-account.sh            # vérifie le compte/souscription Azure avant déploiement
│   ├── audit_tags.sh               # audit des tags obligatoires (gouvernance / FinOps)
│   ├── build_rapport.py            # assemble le rapport final (parties + assets/)
│   └── build_pdf.py                # génère le PDF (WeasyPrint, images embarquées)
├── schemas/                        # schémas d'architecture (Mermaid + PNG exportés)
│   ├── architecture_cible.png      # schéma cible (Partie 1)
│   └── architecture_corrigee.png   # schéma corrigé (Partie 2)
├── screenshots/                    # preuves de validation
│   ├── novaretail_01..10_*.png     # captures du portail Azure
│   └── cli-evidence/               # sorties Azure CLI + Terraform (texte)
└── livrables/
    ├── RAPPORT_FINAL.md            # rapport complet assemblé
    └── RAPPORT_FINAL.pdf           # rapport final (livrable principal)
```

---

## Infrastructure déployée (Resource Group `rg-novaretail-prod`, `swedencentral`)

| Ressource | Nom | Rôle |
|---|---|---|
| Virtual Network + 2 subnets | `vnet-nr-novaretail-prod` | Réseau isolé (web `10.10.1.0/24`, data `10.10.2.0/24`) |
| NSG web / data | `nsg-web`, `nsg-data` | HTTP/HTTPS + SSH restreint / MySQL interne uniquement |
| 2 VM Linux | `vm-web-01`, `vm-web-02` | Serveurs web Apache (Ubuntu 22.04) |
| Load Balancer | `lb-nr-novaretail-prod` | Haute dispo + point d'entrée HTTP (`20.91.200.239`) |
| Storage Account | `stnovaretailja69ku` | Fichiers clients (Blob privé) |
| Log Analytics | `log-nr-novaretail-prod` | Supervision / journalisation |
| Azure DB for MySQL | `mysql-nr-novaretail-prod` | Base managée (MySQL 8.0) |
| Alertes + budget | `alert-cpu-web01`, `alert-storage-availability`, `budget-novaretail-prod` | Monitoring + FinOps |

---

## Reproduire le déploiement

```bash
# 1. Vérifier le compte Azure
./scripts/azure-account.sh

# 2. Déployer l'infrastructure
cd infra && terraform init && terraform plan && terraform apply

# 3. Auditer les tags
cd .. && ./scripts/audit_tags.sh rg-novaretail-prod

# 4. (Re)générer le rapport et le PDF
python3 scripts/build_pdf.py
./scripts/build_zip.sh

# 5. Détruire l'infrastructure (FinOps)
cd ../infra && terraform destroy
```

---

## Livrables (checklist du sujet)

| Livrable | Emplacement | Statut |
|---|---|---|
| Rapport final PDF | `livrables/RAPPORT_FINAL.pdf` | ✅ |
| Schéma d'architecture (PNG) | `schemas/` | ✅ |
| Tableau d'analyse de l'existant | Partie 1 | ✅ |
| Tableau de choix des services | Partie 1 | ✅ |
| Diagnostic architecture défectueuse | Partie 2 | ✅ |
| Matrice de priorisation des risques | Partie 2 | ✅ |
| Dossier Terraform | `infra/` | ✅ |
| Captures de validation | `screenshots/` | ✅ |
| Inventaire des ressources | Partie 4 | ✅ |
| Stratégie de tags | Partie 4 | ✅ |
| Dispositif de monitoring | Partie 5 | ✅ |
| Analyse FinOps | Partie 5 | ✅ |
| Matrice de risques sécurité | Partie 5 | ✅ |
| Note de recommandations DSI | Partie 5 | ✅ |
| Questions théoriques + blockchain | Partie 6 | ✅ |

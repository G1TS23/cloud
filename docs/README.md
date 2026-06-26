# Documentation — module Cloud Computing Azure

> Index de tous les supports du dépôt ShopEasy (EFREI Bordeaux, 2025/2026).

---

## Organisation

```
docs/
├── README.md          ← vous êtes ici
├── cours/             ← Parcours pédagogique débutant (auto-édité, numéroté)
├── tp1/               ← Supports officiels TP1 (EFREI)
└── tp2/               ← Supports officiels TP2 (EFREI)
```

| Dossier | Rôle | Public |
|---|---|---|
| [`cours/`](cours/) | Cours progressifs : contexte, Terraform, code `.tf` ligne par ligne, quiz | Débutant — pour **comprendre** le projet |
| [`tp1/`](tp1/) | Sujet et cours magistral TP1 (PDF) | Référence officielle TP1 |
| [`tp2/`](tp2/) | Sujet, cours magistral et fiche de révision TP2 (PDF + MD) | Référence officielle TP2 |

**Règle simple :**
- Besoin de **réviser l'examen / le cours magistral** → `tp1/` ou `tp2/`
- Besoin de **comprendre le projet depuis zéro** → `cours/` (dans l'ordre des numéros)

---

## Parcours débutant — [`cours/`](cours/)

| # | Fichier |
|---|---|
| — | [Index du parcours](cours/README.md) |
| 01 | [Contexte ShopEasy — TP1 et TP2](cours/01_contexte_shopeasy_tp1_et_tp2.md) |
| 02 | [Terraform — comprendre sans le code](cours/02_terraform_comprendre_sans_le_code.md) |
| 03 | [`network.tf` ligne par ligne](cours/03_network_tf_ligne_par_ligne.md) |
| 04 | [Quiz de validation](cours/04_quiz_validation.md) |
| 05–08 | `security.tf`, `compute.tf`, `loadbalancer.tf`, `storage.tf` — *à venir* |

---

## Supports officiels TP1 — [`tp1/`](tp1/)

| Fichier | Description |
|---|---|
| [TP1_Architecture_Cloud_Azure.pdf](tp1/TP1_Architecture_Cloud_Azure.pdf) | Sujet du TP1 |
| [Cours_Magistral_TP1_Azure.pdf](tp1/Cours_Magistral_TP1_Azure.pdf) | Cours magistral TP1 |

Livrables et code : [`tp1/`](../../tp1/) · [`scripts/deploy_shopeasy.sh`](../../scripts/deploy_shopeasy.sh)

---

## Supports officiels TP2 — [`tp2/`](tp2/)

| Fichier | Description |
|---|---|
| [TP2_Terraform_Azure.md](tp2/TP2_Terraform_Azure.md) · [PDF](tp2/TP2_Terraform_Azure.pdf) | Sujet du TP2 |
| [Cours_Magistral_TP2_Terraform_Azure.md](tp2/Cours_Magistral_TP2_Terraform_Azure.md) · [PDF](tp2/Cours_Magistral_TP2_Terraform_Azure.pdf) | Cours magistral TP2 |
| [Fiche_revision_Terraform.md](tp2/Fiche_revision_Terraform.md) · [PDF](tp2/Fiche_revision_Terraform.pdf) | Fiche de révision (condensée) |

Livrables et code : [`tp2/`](../../tp2/) · [`tp2/terraform/`](../../tp2/terraform/)

> Le parcours débutant ([`cours/`](cours/)) **complète** ces supports officiels ; il ne les remplace pas.

---

## Ailleurs dans le dépôt

| Contenu | Emplacement |
|---|---|
| README principal (déploiement, structure) | [`README.md`](../README.md) à la racine |
| Livrables TP1 | [`tp1/livrables/`](../tp1/livrables/) |
| Livrables TP2 | [`tp2/livrables/`](../tp2/livrables/) |
| Archives PDF/ZIP de rendu | [`dist/`](../dist/) |

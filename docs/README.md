# Documentation — module Cloud Computing Azure

> Index des supports pédagogiques du dépôt ShopEasy (EFREI Bordeaux, 2025/2026).

---

## Organisation

```
docs/
├── README.md          ← vous êtes ici
├── cours/             ← Parcours pédagogique débutant (auto-édité, numéroté)
├── revision/          ← Fiches et glossaire transverses au module
└── examens/           ← Examens blancs

tp1/sujet/  …  tp4/sujet/   ← Sujets officiels, cours magistraux et fiches par TP
```

| Dossier | Rôle | Public |
|---|---|---|
| [`cours/`](cours/) | Cours progressifs : contexte, Terraform, code `.tf` ligne par ligne, quiz | Débutant — pour **comprendre** le projet |
| [`revision/`](revision/) | Glossaire des acronymes, fiche de synthèse globale | Révision transverse au module |
| [`examens/`](examens/) | Examens blancs (MD + PDF) | Préparation à l'évaluation |
| [`tp1/sujet/`](../tp1/sujet/) · [`tp2/sujet/`](../tp2/sujet/) · [`tp3/sujet/`](../tp3/sujet/) · [`tp4/sujet/`](../tp4/sujet/) | Sujets officiels EFREI, cours magistraux, fiches de révision | Référence par TP |

**Règle simple :**
- Besoin du **sujet ou du cours magistral d'un TP** → `tpN/sujet/`
- Besoin de **comprendre le projet depuis zéro** → `cours/` (dans l'ordre des numéros)
- Besoin de **réviser l'examen global** → `revision/` et `examens/`

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

## Révision transverse — [`revision/`](revision/)

| Fichier | Description |
|---|---|
| [Glossaire_acronymes_Cloud_Azure.md](revision/Glossaire_acronymes_Cloud_Azure.md) · [PDF](revision/Glossaire_acronymes_Cloud_Azure.pdf) | Acronymes Azure et cloud |
| [Fiche_synthese_globale_Cloud_Azure.md](revision/Fiche_synthese_globale_Cloud_Azure.md) · [PDF](revision/Fiche_synthese_globale_Cloud_Azure.pdf) | Synthèse du module |

---

## Examens blancs — [`examens/`](examens/)

| Fichier | Description |
|---|---|
| [Examen_blanc_Cloud_Azure.md](examens/Examen_blanc_Cloud_Azure.md) · [PDF](examens/Examen_blanc_Cloud_Azure.pdf) | Examen blanc n°1 |
| [Examen_blanc_2_Cloud_Azure.md](examens/Examen_blanc_2_Cloud_Azure.md) · [PDF](examens/Examen_blanc_2_Cloud_Azure.pdf) | Examen blanc n°2 |

---

## Supports officiels par TP

| TP | Sujet & supports | Livrables & code |
|---|---|---|
| **TP1** — Architecture cloud | [`tp1/sujet/`](../tp1/sujet/) | [`tp1/`](../tp1/) · [`dist/tp1/`](../dist/tp1/) |
| **TP2** — Terraform / IaC | [`tp2/sujet/`](../tp2/sujet/) | [`tp2/`](../tp2/) · [`dist/tp2/`](../dist/tp2/) |
| **TP3** — Administration & automatisation | [`tp3/sujet/`](../tp3/sujet/) | [`tp3/`](../tp3/) · [`dist/tp3/`](../dist/tp3/) |
| **TP4** — Monitoring, FinOps, sécurité | [`tp4/sujet/`](../tp4/sujet/) | [`tp4/`](../tp4/) · [`dist/tp4/`](../dist/tp4/) |

> Le parcours débutant ([`cours/`](cours/)) **complète** les supports officiels ; il ne les remplace pas.

---

## Ailleurs dans le dépôt

| Contenu | Emplacement |
|---|---|
| README principal (déploiement, structure) | [`README.md`](../README.md) à la racine |
| Script de déploiement TP1 | [`scripts/deploy_shopeasy.sh`](../scripts/deploy_shopeasy.sh) |
| Archives PDF/ZIP de rendu | [`dist/`](../dist/) |

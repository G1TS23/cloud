# Rendu TP3 — Administration et Automatisation Azure

> **Module :** Bloc 4 — Cloud Computing · Mastère Dev Manager Full Stack (EFREI)
> **Cas fil rouge :** ShopEasy · **Outils :** Azure CLI · Bash · Python · Azure Monitor
> **Auteurs :** Olivier Falahi & Paul Claverie · **Année :** 2025/2026

Ce document récapitule l'ensemble des livrables du TP3, conformément à la section 17 du sujet. Toutes les commandes ont été exécutées sur l'environnement ShopEasy réellement déployé (Resource Group `rg-shopeasy-dev`, région `swedencentral`, souscription *Azure for Students*).

## Fichier à rendre

> **Le rendu final est livré dans une archive ZIP** (PDF + scripts + code Python + exports + README).

| Fichier | Description |
|---|---|
| `Rendu_TP3_ShopEasy_Administration_Falahi_Claverie.zip` | Archive de rendu complète |
| `TP3_ShopEasy_Administration_Falahi_Claverie.pdf` | Document unique répondant à tout le TP3 |
| `README_RENDU_TP3.md` | Ce mode d'emploi (inclus dans le ZIP) |

Le PDF et le ZIP sont générés via :

```bash
.venv-pdf/bin/python scripts/build_rendu_tp3_pdf.py
```

## Structure du ZIP

```
Rendu_TP3_ShopEasy_Administration_Falahi_Claverie.zip
├── README_RENDU_TP3.md
├── TP3_ShopEasy_Administration_Falahi_Claverie.pdf
├── variables.sh
├── scripts/
│   ├── inventory.sh
│   ├── vm-power.sh
│   └── healthcheck.sh
├── python/
│   ├── inventory.py
│   └── requirements.txt
└── exports/
    ├── resources.tsv
    └── inventory.csv
```

## Contenu du PDF

1. Note technique (synthèse des choix + architecture d'exploitation)
2. Compte rendu des ateliers 1 à 12
3. Analyse FinOps et sécurité
4. Rapport d'exploitation ShopEasy (10 sections + tableau de synthèse)
5. Quiz de validation (20 questions)
6. Annexe A — Arborescence du projet `tp3/`
7. Annexe B — Code source (variables, scripts Bash, script Python)
8. Annexe C — Preuves d'exécution (10 captures)

## Reproduire l'exploitation

```bash
source tp3/variables.sh          # charge RG, LOCATION, VM1/2, STORAGE, etc.
./tp3/scripts/inventory.sh "$RG"             # inventaire + exports
./tp3/scripts/healthcheck.sh "$RG" "$STORAGE" operations
./tp3/scripts/vm-power.sh "$RG" status       # etat des VM
.venv/bin/python tp3/python/inventory.py tp3/exports/inventory.csv
```

> Les fichiers Markdown de `tp3/livrables/` restent la **source éditable** ; le PDF en est la compilation pour le rendu.

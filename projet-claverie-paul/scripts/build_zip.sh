#!/usr/bin/env bash
# build_zip.sh — Assemble le dossier de rendu anonymisé puis génère le ZIP final.
#
# Structure de rendu (alignée sur le sujet, §1.1 et §10) :
#   RENDU_CLOUD_AZURE_NOVARETAIL/
#   ├── README.md
#   ├── RAPPORT_FINAL.pdf      ← livrable principal (contenu intégral + captures + schémas)
#   ├── infra/                 ← code Terraform (sans state / .terraform)
#   ├── schemas/               ← schémas PNG (+ sources .mmd)
#   └── screenshots/           ← captures Portal (PNG uniquement)
#
# Exclus volontairement (déjà dans le PDF ou hors minimum du sujet) :
#   - sujet/          → énoncé fourni par l'établissement
#   - rapport/        → redondant avec le PDF
#   - scripts/        → le pseudo-script Partie 4 est documenté dans le rapport
#   - cli-evidence/   → contient des identifiants personnels (e-mail)
#
# Pré-requis : python3 scripts/build_pdf.py
#   (.venv : pip install pymupdf markdown weasyprint pillow)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

RENDU_NAME="RENDU_CLOUD_AZURE_NOVARETAIL"
DIST_DIR="dist"
STAGE_DIR="$DIST_DIR/$RENDU_NAME"
ZIP_PATH="$DIST_DIR/$RENDU_NAME.zip"

# --- Anonymisation des données personnelles (rendu uniquement) --------------
anonymize_file() {
  local f="$1"
  sed -i \
    -e 's/\*\*Auteur :\*\* Paul Claverie — Mastère/**Évaluation :** épreuve individuelle — niveau Mastère/' \
    -e 's/\*\*Auteur :\*\* Paul Claverie/**Évaluation :** épreuve individuelle/' \
    -e 's/Paul Claverie — Mastère/[identité masquée]/' \
    -e 's/Paul Claverie/[identité masquée]/' \
    -e 's/paul\.claverie@efrei\.net/ops@novaretail.example/' \
    -e 's/paul\.claverie/dsi.ops/' \
    -e 's/efrei-mastere/cc-novaretail/' \
    "$f"
}

echo "==> Nettoyage de l'espace de staging précédent"
rm -rf "$DIST_DIR"/CLAVERIE_PAUL_Cloud_Azure "$DIST_DIR"/CLAVERIE_PAUL_Cloud_Azure.zip
rm -rf "$STAGE_DIR" "$ZIP_PATH"
mkdir -p "$STAGE_DIR"

# --- Vérification du rapport source -----------------------------------------
if [[ ! -f "livrables/RAPPORT_FINAL.pdf" ]]; then
  echo "ERREUR : livrables/RAPPORT_FINAL.pdf introuvable." >&2
  echo "         Génère-le d'abord : python3 scripts/build_rapport.py && cd livrables && npx md-to-pdf RAPPORT_FINAL.md" >&2
  exit 1
fi

PYTHON="${ROOT_DIR}/.venv/bin/python3"
if [[ ! -x "$PYTHON" ]]; then
  echo "==> Création du venv Python (PyMuPDF)"
  python3 -m venv "${ROOT_DIR}/.venv"
  "${ROOT_DIR}/.venv/bin/pip" install -q pymupdf
  PYTHON="${ROOT_DIR}/.venv/bin/python3"
fi

# --- 1. Schémas (PNG requis + sources Mermaid) ------------------------------
echo "==> Copie des schémas"
mkdir -p "$STAGE_DIR/schemas"
cp schemas/*.png "$STAGE_DIR/schemas/" 2>/dev/null || true
cp schemas/*.mmd "$STAGE_DIR/schemas/" 2>/dev/null || true

# --- 2. Captures Portal (PNG uniquement — pas de cli-evidence) --------------
echo "==> Copie des captures Portal (PNG)"
mkdir -p "$STAGE_DIR/screenshots"
cp screenshots/*.png "$STAGE_DIR/screenshots/" 2>/dev/null || true

# --- 3. Code Terraform propre + anonymisé -----------------------------------
echo "==> Copie du code Terraform (anonymisé)"
mkdir -p "$STAGE_DIR/infra"
for f in main.tf variables.tf outputs.tf terraform.tfvars README.md .gitignore; do
  [[ -f "infra/$f" ]] || continue
  cp "infra/$f" "$STAGE_DIR/infra/$f"
  anonymize_file "$STAGE_DIR/infra/$f"
done

# --- 4. Rapport PDF anonymisé -----------------------------------------------
echo "==> Anonymisation du rapport PDF"
"$PYTHON" "$SCRIPT_DIR/anonymize_pdf.py" \
  "livrables/RAPPORT_FINAL.pdf" \
  "$STAGE_DIR/RAPPORT_FINAL.pdf"

# --- 5. README de rendu (sans identité personnelle) -------------------------
echo "==> Génération du README de rendu"
cat > "$STAGE_DIR/README.md" <<'EOF'
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
EOF

# --- 6. Compression ---------------------------------------------------------
echo "==> Création de l'archive ZIP"
( cd "$DIST_DIR" && zip -r -q "$RENDU_NAME.zip" "$RENDU_NAME" )

echo ""
echo "==> Rendu anonymisé : $ZIP_PATH"
echo "------------------------------------------------------------"
( cd "$DIST_DIR" && unzip -l "$RENDU_NAME.zip" )

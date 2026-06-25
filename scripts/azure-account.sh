#!/usr/bin/env bash
#
# azure-account.sh - Bascule SÛRE entre comptes/souscriptions Azure
# (formation vs entreprise) et garde-fou avant tout deploiement.
#
# Objectif : ne JAMAIS deployer sur un abonnement d'entreprise par erreur.
#
# Commandes :
#   ./scripts/azure-account.sh status        Affiche le compte actif (vert=lab / rouge=entreprise)
#   ./scripts/azure-account.sh list          Liste toutes les souscriptions connectees
#   ./scripts/azure-account.sh login         az login (ajouter le compte student)
#   ./scripts/azure-account.sh use-lab       Selectionne la souscription de formation
#   ./scripts/azure-account.sh use <nom|id>  Selectionne une souscription precise
#   ./scripts/azure-account.sh guard         Sort en erreur si le compte actif n'est PAS le lab
#                                            (a chainer avant terraform : guard && terraform apply)
#
# Configuration (par ordre de priorite) :
#   - variable d'env  AZURE_LAB_SUBSCRIPTION_ID
#   - subscription_id present dans tp2/terraform/terraform.tfvars
#
# Liste noire entreprise (toujours bloquee, meme si selectionnee) :
#   domaines / noms definis dans CORP_PATTERNS ci-dessous.

set -euo pipefail

# --- Liste noire entreprise : adapter si besoin -----------------------------
CORP_PATTERNS=("floa.com" "PARIS" "VAL_CBS")

# --- Liste blanche formation : comptes/souscriptions autorises --------------
LAB_PATTERNS=("efrei.net" "Azure for Students")

# --- Couleurs ---------------------------------------------------------------
if [[ -t 1 ]]; then
  RED=$'\e[1;37;41m'; GREEN=$'\e[1;30;42m'; YEL=$'\e[1;30;43m'
  BRED=$'\e[1;31m'; BGRN=$'\e[1;32m'; DIM=$'\e[2m'; RST=$'\e[0m'
else
  RED=""; GREEN=""; YEL=""; BRED=""; BGRN=""; DIM=""; RST=""
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TFVARS="$ROOT/tp2/terraform/terraform.tfvars"

die() { echo "${BRED}Erreur :${RST} $*" >&2; exit 1; }
need_az() { command -v az >/dev/null 2>&1 || die "az CLI introuvable. Installer Azure CLI."; }

lab_id() {
  if [[ -n "${AZURE_LAB_SUBSCRIPTION_ID:-}" ]]; then
    echo "$AZURE_LAB_SUBSCRIPTION_ID"; return
  fi
  if [[ -f "$TFVARS" ]]; then
    grep -E '^\s*subscription_id\s*=' "$TFVARS" 2>/dev/null \
      | head -1 | sed -E 's/.*=\s*"?([^"#[:space:]]+).*/\1/'
  fi
}

is_corp() {
  local hay="$1"
  for p in "${CORP_PATTERNS[@]}"; do
    [[ "$hay" == *"$p"* ]] && return 0
  done
  return 1
}

is_lab() {
  local hay="$1"
  for p in "${LAB_PATTERNS[@]}"; do
    [[ "$hay" == *"$p"* ]] && return 0
  done
  return 1
}

current_json() { az account show -o json 2>/dev/null || true; }

status() {
  need_az
  local j; j="$(current_json)"
  if [[ -z "$j" ]]; then
    echo "${YEL} Aucun compte Azure connecte ${RST}"
    echo "  -> lance : $0 login"
    return 0
  fi
  local name id user tenant
  name="$(echo "$j"  | sed -nE 's/.*"name": *"([^"]*)".*/\1/p' | head -1)"
  id="$(echo "$j"    | sed -nE 's/.*"id": *"([^"]*)".*/\1/p' | head -1)"
  user="$(echo "$j"  | sed -nE 's/.*"name": *"([^"]*)".*/\1/p' | tail -1)"
  tenant="$(echo "$j"| sed -nE 's/.*"tenantId": *"([^"]*)".*/\1/p' | head -1)"

  local lab; lab="$(lab_id || true)"
  local badge color verdict
  if is_corp "$name" || is_corp "$user"; then
    badge="${RED}  ENTREPRISE - NE PAS DEPLOYER  ${RST}"
    color="$BRED"; verdict="bloque par guard"
  elif [[ -n "$lab" && "$id" == "$lab" ]] || is_lab "$name" || is_lab "$user"; then
    badge="${GREEN}  FORMATION - OK pour deployer  ${RST}"
    color="$BGRN"; verdict="autorise"
  else
    badge="${YEL}  COMPTE NON RECONNU - prudence  ${RST}"
    color="$YEL"; verdict="bloque par guard (lab non confirme)"
  fi

  echo
  echo "  $badge"
  echo
  printf "  %-12s ${color}%s${RST}\n" "Souscription" "$name"
  printf "  %-12s %s\n" "ID" "$id"
  printf "  %-12s %s\n" "Compte" "$user"
  printf "  %-12s %s\n" "Tenant" "$tenant"
  [[ -n "$lab" ]] && printf "  %-12s ${DIM}%s${RST}\n" "Lab attendu" "$lab"
  printf "  %-12s %s\n" "Verdict" "$verdict"
  echo
}

cmd_list() {
  need_az
  echo "${DIM}* = souscription active${RST}"
  az account list --query "[].{Actif:isDefault, Nom:name, Compte:user.name, Id:id}" -o table
}

cmd_use() {
  need_az
  [[ $# -ge 1 ]] || die "usage : $0 use <nom|id>"
  az account set --subscription "$1" || die "souscription '$1' introuvable (essaie '$0 list')."
  status
}

cmd_use_lab() {
  need_az
  local lab; lab="$(lab_id || true)"
  [[ -n "$lab" && "$lab" != "00000000-0000-0000-0000-000000000000" ]] \
    || die "Aucun lab configure. Renseigne subscription_id dans tp2/terraform/terraform.tfvars, ou exporte AZURE_LAB_SUBSCRIPTION_ID."
  az account set --subscription "$lab" || die "le lab '$lab' n'est pas dans tes comptes connectes (fais '$0 login')."
  status
}

cmd_login() { need_az; az login; echo; cmd_list; }

guard() {
  need_az
  local j; j="$(current_json)"
  [[ -n "$j" ]] || die "aucun compte Azure connecte."
  local name id user lab
  name="$(echo "$j" | sed -nE 's/.*"name": *"([^"]*)".*/\1/p' | head -1)"
  id="$(echo "$j"   | sed -nE 's/.*"id": *"([^"]*)".*/\1/p' | head -1)"
  user="$(echo "$j" | sed -nE 's/.*"name": *"([^"]*)".*/\1/p' | tail -1)"
  lab="$(lab_id || true)"

  if is_corp "$name" || is_corp "$user"; then
    status; die "compte ENTREPRISE actif ($name / $user). Deploiement refuse."
  fi
  # Confirmation : soit l'ID correspond au lab epingle (terraform.tfvars), soit
  # le compte appartient a la liste blanche formation.
  if [[ -n "$lab" && "$lab" != "00000000-0000-0000-0000-000000000000" && "$id" == "$lab" ]]; then
    echo "${BGRN}guard OK${RST} : souscription de formation epinglee confirmee ($name)."
    return 0
  fi
  if is_lab "$name" || is_lab "$user"; then
    echo "${BGRN}guard OK${RST} : compte de formation reconnu ($name / $user)."
    return 0
  fi
  status; die "compte actif non reconnu comme formation. Configure subscription_id (terraform.tfvars) ou ajoute le a LAB_PATTERNS."
}

case "${1:-status}" in
  status)            status ;;
  list|ls)           cmd_list ;;
  login)             cmd_login ;;
  use-lab|lab)       cmd_use_lab ;;
  use)               shift; cmd_use "$@" ;;
  guard|check)       guard ;;
  *) echo "Commande inconnue : ${1:-}"; sed -nE 's/^# ?//p' "$0" | head -28; exit 1 ;;
esac

#!/usr/bin/env bash
#
# audit_tags.sh — Audit de gouvernance : détecte les ressources sans tags obligatoires.
#
# -------------------------------------------------------------------------
# OBJECTIF
#   Lister toutes les ressources d'un Resource Group qui ne possèdent PAS
#   l'ensemble des tags obligatoires définis par la stratégie de gouvernance
#   NovaRetail (environment, application, owner, cost-center, criticality,
#   review-date). Sert au pilotage FinOps et à la conformité.
#
# ENTRÉES
#   $1 : nom du Resource Group   (défaut : rg-novaretail-prod)
#   Les tags obligatoires sont définis dans REQUIRED_TAGS ci-dessous.
#
# SORTIE
#   - Affichage console : pour chaque tag, les ressources qui ne le portent pas.
#   - Fichier CSV : audit_tags_<rg>_<date>.csv (tag_manquant, ressource).
#   - Code de sortie : 0 si tout est conforme, 3 si des ressources sont non conformes.
#
# LOGIQUE PRINCIPALE
#   1. Pour chaque tag obligatoire, interroge Azure (JMESPath) afin de lister
#      les ressources dont ce tag est absent (tags."<tag>" == null).
#   2. Affiche et enregistre chaque non-conformité, incrémente un compteur.
#   3. Renvoie un code d'erreur si au moins une non-conformité est détectée.
#
# LIMITES
#   - N'inspecte qu'un seul Resource Group à la fois (boucler pour la souscription).
#   - Audit en lecture seule : ne corrige pas automatiquement (par sécurité).
#   - Certaines ressources (sous-réseaux, disques) n'exposent pas toujours de tags :
#     elles apparaîtront comme non conformes, ce qui est un signal de gouvernance utile.
#   - Dépend uniquement d'Azure CLI connecté (az login). Aucune dépendance externe.
# -------------------------------------------------------------------------

set -euo pipefail

RESOURCE_GROUP="${1:-rg-novaretail-prod}"
REQUIRED_TAGS=("environment" "application" "owner" "cost-center" "criticality" "review-date")
DATE_TAG=$(date +%Y%m%d-%H%M%S)
CSV_FILE="audit_tags_${RESOURCE_GROUP}_${DATE_TAG}.csv"

# Vérifications préalables
command -v az >/dev/null 2>&1 || { echo "ERREUR : Azure CLI requis." >&2; exit 1; }
az account show >/dev/null 2>&1 || { echo "ERREUR : exécuter 'az login'." >&2; exit 1; }

echo "Audit des tags obligatoires sur le Resource Group : ${RESOURCE_GROUP}"
echo "Tags requis : ${REQUIRED_TAGS[*]}"
echo "----------------------------------------------------------------------"

echo "tag_manquant,ressource" > "${CSV_FILE}"

TOTAL_RESSOURCES=$(az resource list -g "${RESOURCE_GROUP}" --query "length(@)" -o tsv)
NON_CONFORME=0

for tag in "${REQUIRED_TAGS[@]}"; do
  # JMESPath : ressources dont le tag est absent (null)
  MISSING=$(az resource list -g "${RESOURCE_GROUP}" \
            --query "[?tags.\"${tag}\"==null].name" -o tsv)

  if [[ -n "${MISSING}" ]]; then
    while IFS= read -r res; do
      [[ -z "${res}" ]] && continue
      echo "  [MANQUE: ${tag}] ${res}"
      echo "${tag},${res}" >> "${CSV_FILE}"
      NON_CONFORME=$((NON_CONFORME + 1))
    done <<< "${MISSING}"
  fi
done

echo "----------------------------------------------------------------------"
echo "Ressources dans le groupe : ${TOTAL_RESSOURCES}"
echo "Occurrences non conformes (tag x ressource) : ${NON_CONFORME}"
echo "Rapport CSV : ${CSV_FILE}"

if [[ ${NON_CONFORME} -gt 0 ]]; then
  echo "RÉSULTAT : des ressources ne respectent pas la stratégie de tags."
  exit 3
fi

echo "RÉSULTAT : toutes les ressources sont conformes."
exit 0

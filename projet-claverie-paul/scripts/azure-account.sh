#!/usr/bin/env bash
#
# azure-account.sh — Vérifie le compte Azure utilisé avant tout déploiement.
#
# Objectif : s'assurer que l'on travaille bien sur la bonne souscription
# (Azure for Students) avant de lancer Terraform, afin d'éviter tout
# déploiement sur le mauvais abonnement.
#
# Entrées  : aucune (utilise la session `az login` courante).
# Sortie   : compte, souscription active, tenant, et région cible.
# Limites  : nécessite Azure CLI installé et une session `az login` valide.

set -euo pipefail

EXPECTED_SUBSCRIPTION="Azure for Students"
TARGET_REGION="swedencentral"

echo "=========================================="
echo " Vérification du compte Azure (NovaRetail)"
echo "=========================================="

if ! command -v az >/dev/null 2>&1; then
  echo "ERREUR : Azure CLI (az) n'est pas installé." >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERREUR : aucune session Azure active. Lancez :  az login" >&2
  exit 1
fi

ACCOUNT_NAME=$(az account show --query name -o tsv)
ACCOUNT_USER=$(az account show --query user.name -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_NAME=$(az account show --query tenantDisplayName -o tsv 2>/dev/null || echo "n/a")

echo "Utilisateur        : ${ACCOUNT_USER}"
echo "Souscription       : ${ACCOUNT_NAME}"
echo "Subscription ID    : ${SUBSCRIPTION_ID}"
echo "Tenant             : ${TENANT_NAME}"
echo "Région cible       : ${TARGET_REGION}"
echo "------------------------------------------"

if [[ "${ACCOUNT_NAME}" != "${EXPECTED_SUBSCRIPTION}" ]]; then
  echo "ATTENTION : la souscription active n'est pas « ${EXPECTED_SUBSCRIPTION} »." >&2
  echo "Pour changer :  az account set --subscription \"${EXPECTED_SUBSCRIPTION}\"" >&2
  exit 2
fi

echo "OK : souscription « ${EXPECTED_SUBSCRIPTION} » active."

# Vérifie que la région cible est disponible pour la souscription.
if az account list-locations --query "[?name=='${TARGET_REGION}'].name" -o tsv | grep -q "${TARGET_REGION}"; then
  echo "OK : la région ${TARGET_REGION} est disponible."
else
  echo "ATTENTION : la région ${TARGET_REGION} n'apparaît pas dans les régions disponibles." >&2
fi

echo "=========================================="
echo " Compte vérifié — prêt pour le déploiement."
echo "=========================================="

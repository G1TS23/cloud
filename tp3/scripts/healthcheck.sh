#!/usr/bin/env bash
#
# healthcheck.sh - Controle de sante d'exploitation de l'environnement ShopEasy.
#
# Verifie qu'un groupe de ressources Azure est dans un etat acceptable :
#   1. existence du groupe de ressources ;
#   2. presence d'au moins une VM et affichage de leur etat ;
#   3. ressources sans tag Application ;
#   4. presence d'un tag Owner sur le groupe ;
#   5. alertes Azure Monitor configurees ;
#   6. existence du compte de stockage ;
#   7. existence du conteneur "operations" ;
#   8. au moins une regle NSG autorisant HTTP ou HTTPS.
#
# Code de sortie : 0 si tout est OK, 1 si au moins un avertissement.
#
# Usage :
#   ./healthcheck.sh [resource-group] [storage-account] [container]

set -euo pipefail

RG="${1:-${RG:-rg-shopeasy-dev}}"
STORAGE="${2:-${STORAGE:-}}"
CONTAINER="${3:-${CONTAINER:-operations}}"
STATUS=0

echo "Controle de sante Azure - $RG"
echo "=================================================="

# 1. Groupe de ressources -----------------------------------------------------
echo "1. Verification du groupe de ressources"
if az group show --name "$RG" >/dev/null 2>&1; then
  echo "   OK  - groupe de ressources trouve"
else
  echo "   KO  - groupe de ressources introuvable"
  exit 1
fi

# 2. Machines virtuelles ------------------------------------------------------
echo "2. Verification des VM"
NB_VM=$(az vm list --resource-group "$RG" --query "length(@)" --output tsv)
if [[ "$NB_VM" -ge 1 ]]; then
  echo "   OK  - $NB_VM VM presente(s)"
  az vm list --resource-group "$RG" --show-details \
    --query "[].{name:name,state:powerState,ip:publicIps}" --output table | sed 's/^/      /'
else
  echo "   WARN- aucune VM dans le groupe"
  STATUS=1
fi

# 3. Tag Application sur les ressources --------------------------------------
echo "3. Verification des ressources sans tag Application"
UNTAGGED=$(az resource list --resource-group "$RG" \
  --query "length([?tags.Application==null])" --output tsv)
if [[ "$UNTAGGED" -gt 0 ]]; then
  echo "   WARN- $UNTAGGED ressource(s) sans tag Application"
  STATUS=1
else
  echo "   OK  - tag Application present partout"
fi

# 4. Tag Owner sur le groupe de ressources -----------------------------------
echo "4. Verification du tag Owner sur le groupe"
OWNER=$(az group show --name "$RG" --query "tags.Owner || tags.owner" --output tsv)
if [[ -n "$OWNER" && "$OWNER" != "None" ]]; then
  echo "   OK  - Owner = $OWNER"
else
  echo "   WARN- aucun tag Owner sur le groupe"
  STATUS=1
fi

# 5. Alertes Azure Monitor ----------------------------------------------------
echo "5. Verification des alertes Azure Monitor"
ALERTS=$(az monitor metrics alert list --resource-group "$RG" --query "length(@)" --output tsv)
echo "   Nombre d'alertes : $ALERTS"
if [[ "$ALERTS" -eq 0 ]]; then
  echo "   WARN- aucune alerte configuree"
  STATUS=1
else
  echo "   OK  - alerte(s) presente(s)"
fi

# 6. Compte de stockage -------------------------------------------------------
echo "6. Verification du compte de stockage"
if [[ -z "$STORAGE" ]]; then
  STORAGE=$(az storage account list --resource-group "$RG" --query "[0].name" --output tsv)
fi
if [[ -n "$STORAGE" ]] && az storage account show --name "$STORAGE" --resource-group "$RG" >/dev/null 2>&1; then
  echo "   OK  - compte de stockage $STORAGE present"
else
  echo "   WARN- compte de stockage absent"
  STATUS=1
fi

# 7. Conteneur operations -----------------------------------------------------
echo "7. Verification du conteneur '$CONTAINER'"
if [[ -n "$STORAGE" ]] && az storage container show \
     --account-name "$STORAGE" --name "$CONTAINER" --auth-mode login >/dev/null 2>&1; then
  echo "   OK  - conteneur '$CONTAINER' present"
else
  echo "   WARN- conteneur '$CONTAINER' absent (ou droits insuffisants)"
  STATUS=1
fi

# 8. Regle NSG HTTP/HTTPS -----------------------------------------------------
echo "8. Verification d'une regle NSG autorisant HTTP/HTTPS"
HTTP_RULES=0
for NSG in $(az network nsg list --resource-group "$RG" --query "[].name" --output tsv); do
  N=$(az network nsg rule list --resource-group "$RG" --nsg-name "$NSG" \
    --query "length([?access=='Allow' && direction=='Inbound' && (destinationPortRange=='80' || destinationPortRange=='443')])" \
    --output tsv)
  HTTP_RULES=$((HTTP_RULES + N))
done
if [[ "$HTTP_RULES" -ge 1 ]]; then
  echo "   OK  - $HTTP_RULES regle(s) NSG autorisant HTTP/HTTPS"
else
  echo "   WARN- aucune regle NSG n'autorise HTTP/HTTPS"
  STATUS=1
fi

echo "=================================================="
if [[ "$STATUS" -eq 0 ]]; then
  echo "Resultat : environnement SAIN (tous les controles OK)."
else
  echo "Resultat : avertissement(s) detecte(s) - voir lignes WARN ci-dessus."
fi
exit $STATUS

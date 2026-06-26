#!/usr/bin/env bash
#
# inventory.sh - Inventaire d'exploitation d'un groupe de ressources Azure (ShopEasy).
#
# Produit un inventaire rejouable des ressources et des VM, exporte les
# resultats horodates dans exports/ et affiche des compteurs de synthese
# (total, VM, comptes de stockage, ressources sans tag Application) ainsi
# qu'un avertissement si une VM est encore en cours d'execution.
#
# Usage :
#   ./inventory.sh [resource-group]
#   (a defaut, RG vaut $RG si exporte, sinon rg-shopeasy-dev)

set -euo pipefail

RG="${1:-${RG:-rg-shopeasy-dev}}"
DATE="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="exports"
mkdir -p "$OUT_DIR"

echo "Inventaire Azure - groupe de ressources : $RG"
echo "Date : $DATE"
echo "--------------------------------------------------"

# Verifie que le groupe existe avant tout traitement.
if ! az group show --name "$RG" >/dev/null 2>&1; then
  echo "Erreur : groupe de ressources '$RG' introuvable." >&2
  exit 1
fi

echo "Export des ressources (JSON)..."
az resource list \
  --resource-group "$RG" \
  --query "[].{name:name,type:type,location:location,id:id,tags:tags}" \
  --output json > "$OUT_DIR/resources-$DATE.json"

echo "Export des VM (table)..."
az vm list \
  --resource-group "$RG" \
  --show-details \
  --query "[].{name:name,powerState:powerState,publicIps:publicIps,vmSize:hardwareProfile.vmSize}" \
  --output table > "$OUT_DIR/vms-$DATE.txt"

# --- Compteurs de synthese --------------------------------------------------
TOTAL=$(az resource list --resource-group "$RG" --query "length(@)" --output tsv)
NB_VM=$(az resource list --resource-group "$RG" \
  --query "length([?type=='Microsoft.Compute/virtualMachines'])" --output tsv)
NB_STORAGE=$(az resource list --resource-group "$RG" \
  --query "length([?type=='Microsoft.Storage/storageAccounts'])" --output tsv)
NB_UNTAGGED=$(az resource list --resource-group "$RG" \
  --query "length([?tags.Application==null])" --output tsv)

echo "--------------------------------------------------"
echo "Synthese :"
echo "  Ressources totales       : $TOTAL"
echo "  Machines virtuelles      : $NB_VM"
echo "  Comptes de stockage      : $NB_STORAGE"
echo "  Ressources sans tag App. : $NB_UNTAGGED"

# Avertissement FinOps si une VM tourne encore (cout compute en cours).
RUNNING=$(az vm list --resource-group "$RG" --show-details \
  --query "[?powerState=='VM running'].name" --output tsv || true)
if [[ -n "$RUNNING" ]]; then
  echo "--------------------------------------------------"
  echo "ATTENTION : VM en cours d'execution (cout compute facture) :"
  while IFS= read -r vm; do
    [[ -n "$vm" ]] && echo "  - $vm"
  done <<< "$RUNNING"
fi

echo "--------------------------------------------------"
echo "Export termine dans $OUT_DIR/ :"
echo "  - resources-$DATE.json"
echo "  - vms-$DATE.txt"

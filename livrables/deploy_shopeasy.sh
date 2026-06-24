#!/usr/bin/env bash
#
# TP1 Azure - ShopEasy : déploiement complet de l'architecture cible
# Couvre les ateliers 4 à 11 (Resource Group, réseau, NSG, VM, Load Balancer,
# Storage, Azure SQL, Monitor).
#
# Prérequis :
#   - Azure CLI installée (az), connexion : az login
#   - Un abonnement de TEST / sandbox (JAMAIS de production)
#
# Usage :
#   chmod +x deploy_shopeasy.sh
#   ./deploy_shopeasy.sh            # déploie tout
#   ./deploy_shopeasy.sh cleanup    # supprime le Resource Group
#
set -euo pipefail

# ----------------------------------------------------------------------------
# Variables (adaptez SUFFIX et MY_IP)
# ----------------------------------------------------------------------------
SUFFIX="of24"                       # initiales / numéro de groupe (unicité globale)
LOCATION="francecentral"
RG="rg-shopeasy-dev"

VNET="vnet-shopeasy-dev"
SNET_WEB="snet-web"
SNET_DATA="snet-data"
SNET_ADMIN="snet-admin"

NSG_WEB="nsg-web"
NSG_DATA="nsg-data"

VM1="vm-web-01"
VM2="vm-web-02"
VM_SIZE="Standard_B1s"
VM_IMAGE="Ubuntu2204"
ADMIN_USER="azureuser"

STORAGE="stshopeasy${SUFFIX}"
SQL_SERVER="sql-shopeasy-${SUFFIX}"
SQL_DB="sqldb-shopeasy"
SQL_ADMIN="shopadmin"
SQL_PASSWORD="ChangeMe_$(openssl rand -hex 6)!"   # mot de passe fort généré

LB="lb-shopeasy"

# IP publique de l'apprenant pour l'accès SSH (détection automatique)
MY_IP="$(curl -s https://ifconfig.me || echo '0.0.0.0')"

# ----------------------------------------------------------------------------
# Nettoyage
# ----------------------------------------------------------------------------
if [[ "${1:-}" == "cleanup" ]]; then
  echo ">> Suppression du Resource Group ${RG}..."
  az group delete --name "${RG}" --yes --no-wait
  echo ">> Suppression lancée (no-wait)."
  exit 0
fi

echo ">> IP publique détectée pour SSH : ${MY_IP}"
echo ">> Mot de passe SQL généré : ${SQL_PASSWORD}  (notez-le)"

# ----------------------------------------------------------------------------
# Atelier 4 - Resource Group
# ----------------------------------------------------------------------------
echo ">> [4] Création du Resource Group..."
az group create \
  --name "${RG}" \
  --location "${LOCATION}" \
  --tags projet=shopeasy environnement=dev module=cloud proprietaire="${SUFFIX}"

# ----------------------------------------------------------------------------
# Atelier 5 - Réseau (VNet + subnets)
# ----------------------------------------------------------------------------
echo ">> [5] Création du Virtual Network et des subnets..."
az network vnet create \
  --resource-group "${RG}" \
  --name "${VNET}" \
  --address-prefix 10.10.0.0/16 \
  --subnet-name "${SNET_WEB}" \
  --subnet-prefix 10.10.1.0/24

az network vnet subnet create \
  --resource-group "${RG}" --vnet-name "${VNET}" \
  --name "${SNET_DATA}" --address-prefixes 10.10.2.0/24

az network vnet subnet create \
  --resource-group "${RG}" --vnet-name "${VNET}" \
  --name "${SNET_ADMIN}" --address-prefixes 10.10.3.0/24

# ----------------------------------------------------------------------------
# Atelier 6 - NSG (web + data)
# ----------------------------------------------------------------------------
echo ">> [6] Création des NSG et règles..."
az network nsg create --resource-group "${RG}" --name "${NSG_WEB}"
az network nsg create --resource-group "${RG}" --name "${NSG_DATA}"

# Règles nsg-web
az network nsg rule create --resource-group "${RG}" --nsg-name "${NSG_WEB}" \
  --name allow-http --priority 100 --access Allow --direction Inbound \
  --protocol Tcp --source-address-prefixes Internet --destination-port-ranges 80

az network nsg rule create --resource-group "${RG}" --nsg-name "${NSG_WEB}" \
  --name allow-https --priority 105 --access Allow --direction Inbound \
  --protocol Tcp --source-address-prefixes Internet --destination-port-ranges 443

az network nsg rule create --resource-group "${RG}" --nsg-name "${NSG_WEB}" \
  --name allow-ssh-my-ip --priority 110 --access Allow --direction Inbound \
  --protocol Tcp --source-address-prefixes "${MY_IP}/32" --destination-port-ranges 22

# Règle nsg-data : SQL (1433) uniquement depuis le subnet web
az network nsg rule create --resource-group "${RG}" --nsg-name "${NSG_DATA}" \
  --name allow-sql-from-web --priority 100 --access Allow --direction Inbound \
  --protocol Tcp --source-address-prefixes 10.10.1.0/24 --destination-port-ranges 1433

# Association des NSG aux subnets
az network vnet subnet update --resource-group "${RG}" --vnet-name "${VNET}" \
  --name "${SNET_WEB}" --network-security-group "${NSG_WEB}"
az network vnet subnet update --resource-group "${RG}" --vnet-name "${VNET}" \
  --name "${SNET_DATA}" --network-security-group "${NSG_DATA}"

# ----------------------------------------------------------------------------
# Atelier 7 - Deux VM web (Nginx via cloud-init)
# ----------------------------------------------------------------------------
echo ">> [7] Déploiement des VM web..."
make_cloud_init() {  # $1 = libellé de la page
  cat <<EOF
#cloud-config
package_update: true
packages:
  - nginx
runcmd:
  - echo "ShopEasy - $1" > /var/www/html/index.html
  - systemctl enable nginx
  - systemctl restart nginx
EOF
}
make_cloud_init "VM Web 01" > /tmp/cloudinit-web01.yml
make_cloud_init "VM Web 02" > /tmp/cloudinit-web02.yml

az vm create --resource-group "${RG}" --name "${VM1}" \
  --image "${VM_IMAGE}" --size "${VM_SIZE}" \
  --vnet-name "${VNET}" --subnet "${SNET_WEB}" --nsg "" \
  --admin-username "${ADMIN_USER}" --generate-ssh-keys \
  --public-ip-sku Standard --custom-data /tmp/cloudinit-web01.yml

az vm create --resource-group "${RG}" --name "${VM2}" \
  --image "${VM_IMAGE}" --size "${VM_SIZE}" \
  --vnet-name "${VNET}" --subnet "${SNET_WEB}" --nsg "" \
  --admin-username "${ADMIN_USER}" --generate-ssh-keys \
  --public-ip-sku Standard --custom-data /tmp/cloudinit-web02.yml

# NB : --nsg "" évite la création d'un NSG par VM ; le filtrage est porté
# par le NSG du subnet (nsg-web).

# ----------------------------------------------------------------------------
# Atelier 8 - Load Balancer (frontend + backend pool + sonde + règle)
# ----------------------------------------------------------------------------
echo ">> [8] Création du Load Balancer..."
az network public-ip create --resource-group "${RG}" \
  --name "pip-${LB}" --sku Standard --allocation-method Static

az network lb create --resource-group "${RG}" --name "${LB}" --sku Standard \
  --public-ip-address "pip-${LB}" \
  --frontend-ip-name "fe-${LB}" --backend-pool-name "bepool-web"

az network lb probe create --resource-group "${RG}" --lb-name "${LB}" \
  --name "probe-http" --protocol Http --port 80 --path "/"

az network lb rule create --resource-group "${RG}" --lb-name "${LB}" \
  --name "rule-http" --protocol Tcp --frontend-port 80 --backend-port 80 \
  --frontend-ip-name "fe-${LB}" --backend-pool-name "bepool-web" --probe-name "probe-http"

# Rattachement des cartes réseau des VM au backend pool
for VM in "${VM1}" "${VM2}"; do
  NIC_ID=$(az vm show --resource-group "${RG}" --name "${VM}" --query "networkProfile.networkInterfaces[0].id" -o tsv)
  NIC_NAME=$(basename "${NIC_ID}")
  IPCFG=$(az network nic show --ids "${NIC_ID}" --query "ipConfigurations[0].name" -o tsv)
  az network nic ip-config address-pool add \
    --resource-group "${RG}" --nic-name "${NIC_NAME}" \
    --ip-config-name "${IPCFG}" \
    --lb-name "${LB}" --address-pool "bepool-web"
done

LB_IP=$(az network public-ip show --resource-group "${RG}" --name "pip-${LB}" --query ipAddress -o tsv)
echo ">> Load Balancer accessible sur : http://${LB_IP}"

# ----------------------------------------------------------------------------
# Atelier 9 - Storage Account + conteneurs
# ----------------------------------------------------------------------------
echo ">> [9] Création du Storage Account..."
az storage account create --resource-group "${RG}" --name "${STORAGE}" \
  --location "${LOCATION}" --sku Standard_LRS --kind StorageV2 \
  --https-only true --min-tls-version TLS1_2 --allow-blob-public-access false

# Versioning des blobs
az storage account blob-service-properties update \
  --resource-group "${RG}" --account-name "${STORAGE}" --enable-versioning true

for CONTAINER in factures clients archives; do
  az storage container create --account-name "${STORAGE}" \
    --name "${CONTAINER}" --auth-mode login
done

# ----------------------------------------------------------------------------
# Atelier 10 - Azure SQL Database
# ----------------------------------------------------------------------------
echo ">> [10] Création du serveur et de la base Azure SQL..."
az sql server create --resource-group "${RG}" --name "${SQL_SERVER}" \
  --location "${LOCATION}" --admin-user "${SQL_ADMIN}" --admin-password "${SQL_PASSWORD}"

az sql db create --resource-group "${RG}" --server "${SQL_SERVER}" \
  --name "${SQL_DB}" --edition GeneralPurpose --compute-model Serverless \
  --family Gen5 --capacity 1 --auto-pause-delay 60 \
  --backup-storage-redundancy Local

# Règle de pare-feu temporaire limitée à l'IP de l'apprenant (à supprimer après TP)
az sql server firewall-rule create --resource-group "${RG}" --server "${SQL_SERVER}" \
  --name allow-my-ip --start-ip-address "${MY_IP}" --end-ip-address "${MY_IP}"

# ----------------------------------------------------------------------------
# Atelier 11 - Azure Monitor (alerte CPU sur VM1)
# ----------------------------------------------------------------------------
echo ">> [11] Création d'une alerte CPU..."
VM1_ID=$(az vm show --resource-group "${RG}" --name "${VM1}" --query id -o tsv)
az monitor metrics alert create --resource-group "${RG}" \
  --name "alert-cpu-${VM1}" --scopes "${VM1_ID}" \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m --evaluation-frequency 1m \
  --description "CPU > 80% sur ${VM1}" --severity 2

# ----------------------------------------------------------------------------
# Récapitulatif
# ----------------------------------------------------------------------------
echo ""
echo "================= DÉPLOIEMENT TERMINÉ ================="
echo " Resource Group : ${RG}"
echo " Load Balancer  : http://${LB_IP}"
echo " VM web         : ${VM1}, ${VM2}"
echo " Storage        : ${STORAGE} (factures, clients, archives)"
echo " SQL Server     : ${SQL_SERVER} / base ${SQL_DB}"
echo " SQL admin      : ${SQL_ADMIN} / ${SQL_PASSWORD}"
echo "------------------------------------------------------"
echo " Nettoyage      : ./deploy_shopeasy.sh cleanup"
echo "======================================================"

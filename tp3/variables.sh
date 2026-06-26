#!/usr/bin/env bash
#
# variables.sh - Variables d'exploitation du TP3 ShopEasy (livrable obligatoire).
#
# Usage : se sourcer dans le shell avant d'executer les commandes/scripts du TP.
#   source tp3/variables.sh
#
# Les valeurs ci-dessous sont issues du deploiement Terraform du TP2
# (terraform output, le 26/06/2026). Elles remplacent les valeurs generiques
# du sujet, adaptees a l'environnement reel "Azure for Students".

# --- Perimetre Azure --------------------------------------------------------
export RG="rg-shopeasy-dev"
# Region : francecentral est interdite par la policy Azure for Students,
# l'infrastructure est donc deployee a swedencentral (cf. TP1 et TP2).
export LOCATION="swedencentral"

# --- Machines virtuelles (nommage Terraform : vm-<projet>-<env>-web-N) ------
export VM1="vm-shopeasy-dev-web-1"
export VM2="vm-shopeasy-dev-web-2"

# --- Stockage (nom genere avec suffixe aleatoire par Terraform) -------------
# Recuperable a tout moment via :
#   terraform -chdir=tp2/terraform output -raw storage_account_name
export STORAGE="shopeasydevdocsa0rnay"
# Conteneur d'exploitation a creer au TP3 (le TP2 fournit deja "documents").
export CONTAINER="operations"

# --- Souscription (necessaire au script Python via le SDK Azure) ------------
export AZURE_SUBSCRIPTION_ID="cdca6d99-645a-4251-85e1-f078d1bd66ff"
export AZURE_RESOURCE_GROUP="$RG"

# --- Points d'entree reseau (pour reference / tests applicatifs) ------------
export LB_PUBLIC_IP="20.91.233.129"
export VM1_PUBLIC_IP="135.225.37.122"
export VM2_PUBLIC_IP="4.223.122.111"

echo "Variables TP3 chargees : RG=$RG LOCATION=$LOCATION VM1=$VM1 STORAGE=$STORAGE"

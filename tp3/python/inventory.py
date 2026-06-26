#!/usr/bin/env python3
"""Inventaire programmable des ressources Azure d'un groupe de ressources, via le SDK Azure.

S'authentifie avec DefaultAzureCredential (reutilise la session `az login`),
liste les ressources et les VM du groupe, affiche un resume a l'ecran et
produit un fichier CSV exploitable dans Excel / LibreOffice Calc.

Colonnes du CSV : nom, type, region, tags, role suppose dans l'architecture.

Variables d'environnement attendues :
    AZURE_SUBSCRIPTION_ID  (obligatoire)
    AZURE_RESOURCE_GROUP   (defaut : rg-shopeasy-dev)

Usage :
    pip install -r requirements.txt
    export AZURE_SUBSCRIPTION_ID="<subscription-id>"
    export AZURE_RESOURCE_GROUP="rg-shopeasy-dev"
    python inventory.py [chemin_csv]
"""

from __future__ import annotations

import csv
import os
import sys

from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

# Selon la version du SDK, ResourceManagementClient est expose soit au niveau
# du package azure.mgmt.resource, soit dans le sous-module .resources.
try:
    from azure.mgmt.resource import ResourceManagementClient
except ImportError:
    from azure.mgmt.resource.resources import ResourceManagementClient

# Correspondance type Azure -> role fonctionnel dans l'architecture ShopEasy.
ROLE_BY_TYPE = {
    "Microsoft.Compute/virtualMachines": "Serveur web (VM Linux Nginx)",
    "Microsoft.Compute/disks": "Disque OS managé d'une VM",
    "Microsoft.Network/virtualNetworks": "Réseau privé (VNet)",
    "Microsoft.Network/networkSecurityGroups": "Pare-feu réseau (NSG)",
    "Microsoft.Network/loadBalancers": "Répartiteur de charge HTTP",
    "Microsoft.Network/publicIPAddresses": "Adresse IP publique",
    "Microsoft.Network/networkInterfaces": "Carte réseau d'une VM",
    "Microsoft.Storage/storageAccounts": "Compte de stockage (documents/rapports)",
}


def guess_role(resource_type: str) -> str:
    """Renvoie le role suppose pour un type de ressource, ou une valeur generique."""
    return ROLE_BY_TYPE.get(resource_type, "Autre / non classé")


def format_tags(tags: dict | None) -> str:
    """Serialise les tags en chaine 'cle=valeur;...' lisible dans une cellule CSV."""
    if not tags:
        return ""
    return ";".join(f"{k}={v}" for k, v in sorted(tags.items()))


def main() -> None:
    subscription_id = os.environ.get("AZURE_SUBSCRIPTION_ID")
    resource_group = os.environ.get("AZURE_RESOURCE_GROUP", "rg-shopeasy-dev")
    csv_path = sys.argv[1] if len(sys.argv) > 1 else "exports/inventory.csv"

    if not subscription_id:
        raise SystemExit("Variable AZURE_SUBSCRIPTION_ID manquante.")

    credential = DefaultAzureCredential()
    resource_client = ResourceManagementClient(credential, subscription_id)
    compute_client = ComputeManagementClient(credential, subscription_id)

    print(f"Inventaire du groupe : {resource_group}")
    print("Ressources :")

    rows: list[dict[str, str]] = []
    for res in resource_client.resources.list_by_resource_group(resource_group):
        print(f"- {res.name} | {res.type} | {res.location}")
        rows.append(
            {
                "nom": res.name,
                "type": res.type,
                "region": res.location,
                "tags": format_tags(res.tags),
                "role": guess_role(res.type),
            }
        )

    print("\nMachines virtuelles :")
    for vm in compute_client.virtual_machines.list(resource_group):
        size = vm.hardware_profile.vm_size
        print(f"- {vm.name} | taille={size} | region={vm.location}")

    # Ecriture du CSV (UTF-8 avec BOM pour une ouverture propre dans Excel).
    os.makedirs(os.path.dirname(csv_path) or ".", exist_ok=True)
    with open(csv_path, "w", newline="", encoding="utf-8-sig") as fh:
        writer = csv.DictWriter(
            fh, fieldnames=["nom", "type", "region", "tags", "role"], delimiter=";"
        )
        writer.writeheader()
        writer.writerows(rows)

    print(f"\n{len(rows)} ressource(s) exportee(s) dans {csv_path}")


if __name__ == "__main__":
    main()

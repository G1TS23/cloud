# Schéma d'architecture cible — ShopEasy

Deux formats fournis :

- **`architecture.mmd`** — diagramme Mermaid. Rendu instantané sur https://mermaid.live (copier/coller), ou via une extension Mermaid (VS Code, Obsidian). Exporter ensuite en PNG/SVG/PDF.
- **`architecture.drawio`** — fichier importable dans https://app.diagrams.net (draw.io), Lucidchart ou Visio (via import draw.io). Permet d'éditer puis d'exporter en PDF/PNG comme demandé dans l'atelier 3.

## Légende

| Couleur | Signification |
|---|---|
| 🔴 Rouge | Composant exposé à Internet (Load Balancer, subnet web) |
| 🔵 Bleu | Composant interne (VM, Azure SQL, Storage, subnets data) |
| 🟡 Jaune | Gouvernance / supervision (Entra ID, RBAC, Azure Monitor) |

## Flux principaux

1. **Internet → Load Balancer** (HTTP 80 / HTTPS 443) → réparti vers `vm-web-01` / `vm-web-02`.
2. **Admin → VM** : SSH 22 restreint à l'IP de l'apprenant (Bastion en production).
3. **VM web → Azure SQL** : port 1433, uniquement depuis le subnet web (NSG `nsg-data`).
4. **VM web → Storage Account** : HTTPS via SDK/API (documents clients).
5. **Tous les composants → Azure Monitor** : métriques, logs et alertes.
6. **Entra ID + RBAC** : contrôle d'accès transverse sur le Resource Group.

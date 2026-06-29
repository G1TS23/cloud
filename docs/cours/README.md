# Parcours pédagogique — ShopEasy & Terraform

> Cours progressifs **auto-édités** pour comprendre le module Cloud Computing Azure depuis zéro.  
> Ils **complètent** les supports officiels dans [`tp1/sujet/`](../../tp1/sujet/) et [`tp2/sujet/`](../../tp2/sujet/) — voir [`docs/README.md`](../README.md).

**Ordre recommandé :** suivre les numéros dans l'ordre.

| # | Cours | Objectif | Statut |
|---|---|---|---|
| **01** | [Contexte ShopEasy — TP1 et TP2](01_contexte_shopeasy_tp1_et_tp2.md) | Comprendre le projet, les attentes et la différence entre les deux TPs | ✅ |
| **02** | [Terraform — comprendre sans le code](02_terraform_comprendre_sans_le_code.md) | Outils, workflow, state, variables — avant de lire les `.tf` | ✅ |
| **03** | [`network.tf` ligne par ligne vs bash TP1](03_network_tf_ligne_par_ligne.md) | Resource Group, VNet, subnets — commande `az` ↔ code HCL | ✅ |
| **04** | [Quiz de validation](04_quiz_validation.md) | 25 questions pour tester sa compréhension | ✅ |
| **05** | `security.tf` ligne par ligne vs bash TP1 | NSG, règles, associations | 🔜 à venir |
| **06** | `compute.tf` ligne par ligne vs bash TP1 | VM, NIC, IP publique, cloud-init | 🔜 à venir |
| **07** | `loadbalancer.tf` ligne par ligne vs bash TP1 | Load Balancer, sonde, règles | 🔜 à venir |
| **08** | `storage.tf` ligne par ligne vs bash TP1 | Storage Account, conteneur blob | 🔜 à venir |

---

## Supports officiels (référence EFREI)

| Support | Emplacement |
|---|---|
| Index documentation | [`docs/README.md`](../README.md) |
| Sujet + magistral TP1 | [`tp1/sujet/README.md`](../../tp1/sujet/README.md) |
| Sujet + magistral + fiche révision TP2 | [`tp2/sujet/README.md`](../../tp2/sujet/README.md) |
| Script bash TP1 | [`scripts/deploy_shopeasy.sh`](../../scripts/deploy_shopeasy.sh) |
| Code Terraform TP2 | [`tp2/terraform/`](../../tp2/terraform/) |

---

## Parcours suggéré

```
01 Contexte           →  Pourquoi ShopEasy ? Qu'a-t-on fait au TP1 ?
        ↓
02 Terraform (théorie) →  À quoi sert Terraform ? Workflow, state…
        ↓
03–08 Code (.tf)      →  Un fichier Terraform = un cours, relié au bash TP1
        ↓
04 Quiz               →  Vérifier qu'on a compris (après 02 minimum, idéal après 03+)
```

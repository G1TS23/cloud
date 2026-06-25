# TP2 Terraform — Quiz de validation (réponses)

> Réponses aux 20 questions de la section 21 du sujet `TP2_Terraform_Azure.md`.

1. **Terraform est-il impératif ou déclaratif ? Justifier.**
   **Déclaratif.** On décrit l'état final souhaité de l'infrastructure ; Terraform calcule lui-même la suite d'opérations (créer/modifier/détruire) nécessaire pour l'atteindre. On ne liste pas les étapes une à une.

2. **Rôle d'un provider Terraform ?**
   C'est un plugin qui traduit les ressources HCL en appels d'API d'une plateforme. Ici `azurerm` pilote l'API Azure Resource Manager ; `random` génère des valeurs aléatoires.

3. **À quoi sert `terraform.tfstate` ?**
   Il mémorise la correspondance entre les ressources déclarées dans le code et les ressources réellement créées dans le cloud (IDs, attributs). C'est la source de vérité de Terraform pour calculer les `plan`.

4. **Pourquoi `terraform plan` avant `terraform apply` ?**
   Pour prévisualiser les changements (créations `+`, modifications `~`, destructions `-`, remplacements `-/+`) et détecter toute action dangereuse avant d'impacter Azure.

5. **Quelle commande formate le code ?**
   `terraform fmt`.

6. **Quelle commande vérifie la syntaxe et la cohérence ?**
   `terraform validate`.

7. **Quel service Azure correspond au réseau privé logique ?**
   Le **Virtual Network (VNet)**.

8. **Quel composant filtre les flux réseau entrants/sortants ?**
   Le **Network Security Group (NSG)**.

9. **Pourquoi restreindre SSH à une seule IP ?**
   Pour réduire drastiquement la surface d'attaque et limiter le brute-force : seul le poste de l'administrateur peut tenter une connexion.

10. **Intérêt de `count` pour les VM ?**
    Déployer plusieurs instances identiques depuis un seul bloc (indexées par `count.index`), sans duplication de code, et faire varier facilement le nombre d'instances.

11. **Pourquoi utiliser des variables ?**
    Pour éviter les valeurs codées en dur, paramétrer le projet et le réutiliser sur plusieurs environnements (dev/test/prod) sans modifier le code.

12. **Pourquoi utiliser des outputs ?**
    Pour exposer après déploiement les informations utiles (IP du Load Balancer, nom du RG, nom du Storage) aux utilisateurs, scripts ou modules consommateurs.

13. **Pourquoi taguer les ressources ?**
    Pour la gouvernance et le FinOps : identifier le projet, l'environnement, le propriétaire et le centre de coût, faciliter le reporting des coûts et le cycle de vie.

14. **Différence entre un changement Terraform et un changement manuel dans le portail ?**
    Le changement Terraform est tracé (Git), revu, reproductible et applique l'état déclaré. Le changement manuel n'est pas tracé, crée une **dérive** (drift) et n'est pas reproductible.

15. **Quel risque présente un Storage Account public ?**
    Fuite de données : accès anonyme aux blobs (documents métier, données clients), exfiltration et non-conformité (RGPD).

16. **Pourquoi le versioning Blob peut-il générer des coûts ?**
    Chaque version antérieure d'un blob est conservée et facturée comme du stockage supplémentaire ; le volume cumulé croît à chaque modification.

17. **À quoi sert un Load Balancer ?**
    À répartir le trafic entre plusieurs VM et améliorer la disponibilité (bascule automatique via sonde de santé en cas de défaillance d'une instance).

18. **Pourquoi un state distant est-il préférable en équipe ?**
    State partagé et centralisé, avec verrouillage (évite les `apply` concurrents corrompant le state), sécurisable (RBAC, chiffrement) et intégrable en CI/CD.

19. **Deux bonnes pratiques de sécurité pour un projet Terraform.**
    (a) Ne jamais stocker de secrets dans le code/`tfvars` versionné (Key Vault, variables d'environnement, variables CI/CD sécurisées). (b) Restreindre les accès réseau (SSH limité par IP, pas de `0.0.0.0/0`, Storage privé) et protéger le state distant par RBAC.

20. **Deux améliorations pour se rapprocher d'un environnement de production.**
    (a) Supprimer les IP publiques des VM et administrer via **Azure Bastion** ; externaliser le state dans un **backend Azure** sécurisé. (b) Ajouter une **Application Gateway + WAF**, un **subnet privé** pour les données, une pipeline **CI/CD** (`fmt`/`validate`/`plan`/approbation) et de l'**observabilité** (Azure Monitor / Log Analytics).

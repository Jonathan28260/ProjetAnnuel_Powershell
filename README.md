
![alt text](https://raw.githubusercontent.com/Jonathan28260/ProjetAnnuel_Powershell/main/Logo/Logo_Sciences-U_Lyon.ico)
![alt text](https://raw.githubusercontent.com/Jonathan28260/ProjetAnnuel_Powershell/main/Logo/Logo_ESGI.ico)

# Projet annuel powershell
```
Projet d'automatisation du déploiement d'une infrastructure via script powershell dans Azure 
```

## Normalisation des noms:
```
 PPS2022 = Projet PowerShell 2022
```

### Exemple script:
```
 PPS2022-FONCTIONduSCRIPT
 
 PPS2022-Deploiement
``` 

### Exemple nom d'une VM:
```
 PPS2022-srv-SERVICESDEPLOIE
 
 PPS2022-srv-AD
```
## Liste des scripts et leurs fonctions:
```
 PPS2022-Deploiement.ps1  ---> Script déploiement infrastructure Azure
 
 PPS2022-InstallServices.ps1 ---> Script d'installation des services AD/DNS/DHCP/IIS
 
 PPS2022-Supervision.ps1 ---> Script de supervision HTML
 
 PPS2022-Template-ARM-DC.json ---> Template ARM utilisé pour le déploiement du contrôleur de domaine
 
 PPS2022-Template-ARM-IIS.json ---> Template ARM utilisé pour le déploiement du serveur web
```
## Comment utiliser les scripts

### Deploiement
```
- Le projet étant entièrement automatisé, il n'est nécéssaire que d'exécuter le script PPS2022-Deploiement.ps1
Tous les autres scripts et templates ARM sont appelés à partir du script de déploiement.

- Une fois le script de déploiement exécuté, une vérification du module Azure pour powershell est réalisée pour vérifier si le module est installé.
Si le module n'est pas installé le script va le télécharger et l'installer automatiquement pour prendre en charge le reste des commandes du script deploiement.

- Après la vérification/installation du module Azure, une demande d'identifiants sera affichée pour la connexion au compte Azure.
La demande d'identifiants est sous forme d'une fenêtre interactive et enregistre le mot de passe fournis en tant qu'objet PSCredential.

- Le script va par la suite créer un groupe de ressource "PPS2022-RG", puis appeler les templates ARM pour déployer les machines virtuelles ainsi que les ressources nécéssaire.
```
### Template ARM
```
Les ressources déployées avec la template ARM
```
![alt text](https://github.com/Jonathan28260/ProjetAnnuel_Powershell/blob/main/Logo/Ressources.png)

```
Les paramètres utilisés par la template ARM
```
![alt text](https://github.com/Jonathan28260/ProjetAnnuel_Powershell/blob/main/Logo/Param%C3%A8tres.png)

```
Les variables utilisés par la template ARM
```
![alt text](https://github.com/Jonathan28260/ProjetAnnuel_Powershell/blob/main/Logo/Variables.png)

### Installation des services
```
L'installation des services est également entièrement automatisé.
Le script "PPS2022-InstallServices.ps1" est appelé par la template "PPS2022-Template-ARM-DC.json" grâce à la ressource "Microsoft.Compute/virtualMachines/extensions" et l'extension "CustomScriptExtension".
```

### Monitoring
```

```

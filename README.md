
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
 
 PPS2022-Template-ARM-DC.json ---> Template ARM utilisé pour le déploiement du contrôleur de doaine
 
 PPS2022-Template-ARM-IIS.json ---> Template ARM utilisé pour le déploiement du serveur web
```

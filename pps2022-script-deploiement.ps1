#Définir les régles d'éxecution des modules#
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

#Installer le module Azure Powershell#
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

#Demande des identifiants
$credential = Get-Credential

# Login to the Azure console
Login-AzAccount -Credential $credential

#Créer un groupe de ressources#
New-AzResourceGroup `
  -Name ProjetPowershell `
  -Location "France Central"

#New-AzResourceGroup -Name ProjetPowershell -Location 'France Central'

#Utiliser une template ARM#
$TemplateARM = "C:\Users\Victo\Desktop\Template_ARM_Projet_Powershell.json"
New-AzResourceGroupDeployment `
  -Name DeploiementProjet `
  -ResourceGroupName ProjetPowershell `
  -TemplateFile $TemplateARM

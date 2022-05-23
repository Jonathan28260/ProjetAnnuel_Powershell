function VerificationModuleAz {
    # # #Définir les régles d'éxecution des modules#
    # Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

    # # #Installer le module Azure Powershell#
    # Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}
VerificationModuleAZ

function CreationRG {
    #Demande des identifiants
    $credential = Get-Credential

    # Login to the Azure console
    Login-AzAccount -Credential $credential

    #Créer un groupe de ressources#
    New-AzResourceGroup -Name ProjetPowershell -Location 'Switzerland North'
}
CreationRG

function DeploiementARM {
    #Utiliser une template ARM#
    $TemplateARM = ".\PPS2022-Template-ARM-DC+IIS.json"
    New-AzResourceGroupDeployment -Name DeploiementProjet -ResourceGroupName ProjetPowershell -TemplateFile $TemplateARM
}
DeploiementARM

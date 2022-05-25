function VerificationModuleAz {
    # # #Définir les régles d'éxecution des modules#
    # Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

    # # #Installer le module Azure Powershell#
    Install-Module -Name Az -AllowClobber -Scope AllUsers -Force 
}


function CreationRG {
    #Demande des identifiants
    $credential = Get-Credential -Message "Veuillez entrer les identifiants de votre compte Azure"

    # Connexion à la console Azure
    Login-AzAccount -Credential $credential

    #Créer un groupe de ressources#
    New-AzResourceGroup -Name "PPS2022-RG" -Location 'Switzerland North'
}
CreationRG


function DeploiementARM {
    #Utilisation des templates ARM#
    $TemplateARM = ".\PPS2022-Template-ARM-DC+IIS.json"
    New-AzResourceGroupDeployment -Name "PPS2022-ARM-DC" -ResourceGroupName "PPS2022-RG" -TemplateFile $TemplateARM
}
DeploiementARM


Remove-AzResourceGroup -Name "PPS2022-RG"
Remove-AzResourceGroup -Name "NetworkWatcherRG"

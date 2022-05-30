function VerificationModuleAz {
    # # #Définir les régles d'éxecution des modules#
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

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
# CreationRG


function DeploiementARM {
    #Utilisation des templates ARM#
    $TemplateARM = ".\PPS2022-Template-ARM-DC+IIS.json"
    New-AzResourceGroupDeployment -Name "PPS2022-ARM" -ResourceGroupName "PPS2022-RG" -TemplateFile $TemplateARM -Verbose
}
# DeploiementARM

function SuppressionRessources{
    #Suppresion des ressources Azure
    Remove-AzResourceGroup -Name "PPS2022-RG"
    Remove-AzResourceGroup -Name "NetworkWatcherRG"   
}

function DisplayMenu{
    $continue = $true
    while ($continue){
        write-host "---------------SCRIPT de Déploiement--------------------"
        write-host "1. Verifier le module Az sur le poste local"
        write-host "2. Connexion à Azure et création RG"
        write-host "3. Déploiement ARM"
        write-host "4. Supression des ressources"
        write-host "5. Exit"
        write-host "--------------------------------------------------------"
        $choix = read-host "Faire un choix"
        switch ($choix){
            1{VerificationModuleAz}
            2{CreationRG}
            3{DeploiementARM}
            4{SuppressionRessources}
            5{$continue = $false}

        default {Write-Host "Choix invalide"-ForegroundColor Red}
        }
    }
}
DisplayMenu

function PPS2022VerificationModuleAz {
    # # #Définir les régles d'éxecution des modules#
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

    # # #Installer le module Azure Powershell#
    Install-Module -Name Az -Scope AllUsers -Force 
}


function PPS2022CreationRG {
    #Demande des identifiants
    $credential = Get-Credential -Message "Veuillez entrer les identifiants de votre compte Azure"

    # Connexion à la console Azure
    Login-AzAccount -Credential $credential

    #Créer un groupe de ressources#
    New-AzResourceGroup -Name "PPS2022-RG" -Location 'Switzerland North'
}
# CreationRG


function PPS2022DeploiementARM {
    #Utilisation des templates ARM#
    $TemplateARM = ".\PPS2022-Template-ARM-DC+IIS.json"
    New-AzResourceGroupDeployment -Name "PPS2022-ARM" -ResourceGroupName "PPS2022-RG" -TemplateFile $TemplateARM -Verbose
}


function PPS2022SuppressionRessources{
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
            1{PPS2022VerificationModuleAz}
            2{PPS2022CreationRG}
            3{PPS2022DeploiementARM}
            4{PPS2022SuppressionRessources}
            5{$continue = $false}

        default {Write-Host "Choix invalide"-ForegroundColor Red}
        }
    }
}
DisplayMenu

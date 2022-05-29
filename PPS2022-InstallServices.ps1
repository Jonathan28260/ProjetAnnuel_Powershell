# On donne la valeur "stop" à la variable $ErrorActionPreference afin que les Try/Catch fonctionnent
$ErrorActionPreference = "stop"

function PPS2022TestWinRM{

    #On récupère le statut du service WinRM, s'il est éteint alors on démarre le service
    if(Get-Service -Name Winrm | Where-Object {$_.status -NotLike "Running"})
        {
            try{
                Start-Service WinRM
                Write-Host -Object "Le service WinRM a ete demarre" -ForegroundColor Yellow
            }

            catch{
                #Si le try ne fonctionne pas alors on affiche l'erreur.
                Write-Host $Error[0].Exception.Message -ForegroundColor Red
            }
        }

    else
        {
            Write-Host -Object "Le service WinRM est deja demarre" -ForegroundColor Green
        }

Read-Host "Appuyez sur ENTREE pour continuer..."

}

#Fonction pour installation et configuration de l'AD
function PPS2022InstallAD{

    #Initialisation de la session Powershell à distance
    Try{
        $sessionId = New-PSSession -ComputerName pps2022srvdc.switzerlandnorth.cloudapp.azure.com -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -Credential "PPS2022\Administrateur"
    }

    Catch{
        Write-Host $Error[0].Exception.Message -ForegroundColor Red
    }
    
    #Si la PSSession a bien été initialisée alors on envoi les commandes suivantes sur le serveur distant
    if($sessionId){

    #Recuperation du SafePassword pour la foret ActiveDirectory
    $safePassword = Read-Host "Entrer le SafePassword pour la foret Active Directory" -AsSecureString
    
    #Envoi du bloc de code suivant sur le serveur distant avec comme argument le SafePassword entré au dessus
    Invoke-Command -Session $sessionId -ArgumentList $safePassword -Scriptblock {
        #On vérifie si l'active directory est déjà installé sur le serveur
        $verifAD = Get-ADDomainController -ErrorAction SilentlyContinue
        #Si le service n'est pas installé alors on installe l'AD et la forêt.
        if(!$verifAD)
        {
            Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
            Install-ADDSForest -DomainName PPS2022.local -DomainNetBiosName PPS2022 -InstallDns:$true -NoRebootOnCompletion:$false -SafeModeAdministratorPassword $args[0] -Force
        }

    }
    #On supprime la PSSession créé plus tôt
    Remove-PSSession $sessionId
    # Restart-Computer -ComputerName $computerName -Wait -For PowerShell -Timeout 300 -Delay 2 -Credential $computerCredentials -Force
    Write-Host -Object "Le serveur a redemarre" -ForegroundColor Green
    Write-Host -Object "Le service AD a bien ete installe" -ForegroundColor Green
    }

    else{
        Write-Error "La session powershell n'a pas pu etre etablie. Veuillez verifier les identifiants."
    }
}

#Fonction pour installation et configuration du service DHCP
function PPS2022InstallDHCP{
    #On essaie de créer la PSSession sur le serveur distant
    try {
        $sessionId = New-PSSession -ComputerName pps2022srvdc.switzerlandnorth.cloudapp.azure.com -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -Credential "PPS2022\Administrateur"
    }
    #On affiche l'erreur si le Try échoue
    catch {
        Write-Host $Error[0].Exception.Message -ForegroundColor Red
    }
    #Si la PSSession a bien été créée alors on essaie d'installer le service DHCP
    if($sessionId){
        Try{
            Invoke-Command -Session $sessionId -Scriptblock {
                #On installe le service DHCP
                Install-WindowsFeature DHCP -IncludeManagementTools
                #On lie le serveur DHCP au domaine
                Add-DHCPServerInDC -DNSName ([System.Net.Dns]::GetHostByName($env:computerName).HostName)
                #On donne l'adresse du serveur DNS, le nom de domaine et l'adresse IP de la passerelle en paramètre
                Set-DHCPServerv4OptionValue -DNSServer 192.168.1.10 -DNSDomain PPS2022.local -Router 192.168.1.1
                #On créer notre pool DHCP "Pool PPS2022"
                Add-DHCPServerv4Scope -Name "Pool PPS2022" -StartRange 192.168.1.50 -EndRange 192.168.1.100 -SubnetMask 255.255.255.0 -Description "Plage DHCP pour projet PPS2022"
            } -ErrorAction SilentlyContinue

        Write-Host -Object "Le service DHCP a ete installe" -ForegroundColor Green
        }

        catch{
            Write-Host $Error[0].Exception.Message -ForegroundColor Red
        }
        #On supprime la PSSession
        Remove-PSSession $sessionId
    }
}

#Fonction pour l'affichage du menu (Interface utilisateur)
function PPS2022DisplayMenu{
    $continue = $true
    #On boucle tant que la variable $continue est égal à $true
    while ($continue){
        write-host "----------SCRIPT INSTALLATION DES SERVICES -------------"
        write-host "1. Verifier WinRM sur le poste local"
        write-host "2. Installer le service Active Directory"
        write-host "3. Installer le service DHCP"
        write-host "4. Exit"
        write-host "--------------------------------------------------------"
        $choix = read-host "Faire un choix"
        
        #On conditionne avec un switch en invitant l'utilisateur à sélectionner une option afin d'exécuter la fonction demandée.
        switch ($choix){
            1{PPS2022TestWinRM}
            2{PPS2022InstallAD}
            3{PPS2022InstallDHCP}
            4{$continue = $false}

        default {Write-Host "Choix invalide"-ForegroundColor Red}
        }
    }
}

#On affiche le menu
PPS2022DisplayMenu

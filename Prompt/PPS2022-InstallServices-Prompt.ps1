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
function PPS2022InstallAD{

    #Recuperation de l'IP ou nom de l'ordinateur distant pour pouvoir s'y connecter
    $computerName = Read-Host -Prompt "Veuillez entrer le nom du serveur auquel vous souhaiter accéder"

    #Recuperation des informations d'identification pour l'ordinateur cible
    $computerCredentials = Get-Credential -Message "Identifants de l'ordinateur distant"

    #Initialisation de la session Powershell à distance
    Try{
        $sessionId = New-PSSession -ComputerName $computerName -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -Credential $computerCredentials
    }

    Catch{
        Write-Host $Error[0].Exception.Message -ForegroundColor Red
    }

    #Recuperation du SafePassword pour la foret ActiveDirectory
    $safePassword = Read-Host "Entrer le SafePassword pour la foret Active Directory" -AsSecureString
    
    #Si la PSSession a bien été initialisée alors on envoi les commandes suivantes sur le serveur distant
    if($sessionId){
    Invoke-Command -Session $sessionId -ArgumentList $safePassword -Scriptblock {

        $verifAD = Get-ADDomainController -ErrorAction SilentlyContinue
    
        if(!$verifAD)
        {
            $domainName = Read-Host -Prompt "Veuillez entrer le nom de domaine complet (Ex: Test.local)"
            $netbiosName = Read-Host -Prompt "Veuillez entrer le nom Netbios (Ex: Test)"
            Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
            Install-ADDSForest -DomainName $domainName -DomainNetBiosName $netbiosName -InstallDns:$true -NoRebootOnCompletion:$false -SafeModeAdministratorPassword $args[0] -Force
        }

    } -ErrorAction SilentlyContinue

    Remove-PSSession $sessionId
    Write-Host -Object "Le serveur a redemarre" -ForegroundColor Green
    Write-Host -Object "Le service AD a bien ete installe" -ForegroundColor Green
    }

    else{
        Write-Error "La session powershell n'a pas pu etre etablie. Veuillez verifier les identifiants."
    }
}

function PPS2022InstallDHCP{
    $computerCredentials = Get-Credential -Message "Identifants de l'ordinateur distant"
    $computerName = Read-Host -Prompt "Veuillez entrer le nom du serveur auquel vous souhaitez accéder"

    try {
        $sessionId = New-PSSession -ComputerName $computerName -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -Credential $computerCredentials
    }
    catch {
        Write-Host $Error[0].Exception.Message -ForegroundColor Red
    }

    $dnsServer = Read-Host -Prompt "Veuillez entrer l'adresse IP du serveur DNS"
    $dnsDomain = Read-Host -Prompt "Veuillez entrer le nom de domaine (Ex: ESGI.local)"
    $gatewayIP = Read-Host -Prompt "Veuillez entrer l'adresse IP de la passerelle"
    $poolName = Read-Host -Prompt "Veuillez entrer le nom du pool DHCP"
    $ipStartRange = Read-Host -Prompt "Veuillez entrer la premiere adresse IP du pool DHCP"
    $ipEndRange = Read-Host -Prompt "Veuillez entrer la derniere adresse IP du pool"
    $ipMask = Read-Host -Prompt "Veuillez entrer le masque de sous reseau pour le pool"
    $poolDescription = Read-Host -Prompt "Veuillez entrer une description pour votre pool DHCP"
    
    try{
        Invoke-Command -Session $sessionId -ArgumentList $dnsServer,$dnsDomain,$gatewayIP,$poolName,$ipStartRange,$ipEndRange,$ipMask,$poolDescription -Scriptblock {
            Install-WindowsFeature DHCP -IncludeManagementTools
            Add-DHCPServerInDC -DNSName ([System.Net.Dns]::GetHostByName($env:computerName).HostName)
            Set-DHCPServerv4OptionValue -DNSServer $args[0] -DNSDomain $args[1] -Router $args[2]
            Add-DHCPServerv4Scope -Name $args[3] -StartRange $args[4] -EndRange $args[5] -SubnetMask $args[6] -Description $args[7]
        }

        Write-Host -Object "Le service DHCP a ete installe"
    }

    catch{
        Write-Host $Error[0].Exception.Message -ForegroundColor Red
    }

    Remove-PSSession $sessionId
}

function PPS2022DisplayMenu{
    $continue = $true
    while ($continue){
        write-host "----------SCRIPT INSTALLATION DES SERVICES -------------"
        write-host "1. Verifier WinRM sur le poste local"
        write-host "2. Installer le service Active Directory"
        write-host "3. Installer le service DHCP"
        write-host "4. Exit"
        write-host "--------------------------------------------------------"
        $choix = read-host "Faire un choix"
        switch ($choix){
            1{PPS2022TestWinRM}
            2{PPS2022InstallAD}
            3{PPS2022InstallDHCP}
            4{$continue = $false}
            
        default {Write-Host "Choix invalide"-ForegroundColor Red}
        }
    }
}

DisplayMenu

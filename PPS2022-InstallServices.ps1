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

    #Initialisation de la session Powershell à distance
    Try{
        #$sessionId = New-PSSession -ComputerName $computerName -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -Credential $computerCredentials
        $sessionId = New-PSSession -ComputerName pps2022srvdc.switzerlandnorth.cloudapp.azure.com -Credential Administrateur
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
            Install-ADDSForest -DomainName $domainName -DomainNetBiosName $netbiosName -InstallDns:$true -NoRebootOnCompletion:$true -SafeModeAdministratorPassword $args[0] -Force
            Restart-Computer
        }

    }

    Remove-PSSession $sessionId
    # Restart-Computer -ComputerName $computerName -Wait -For PowerShell -Timeout 300 -Delay 2 -Credential $computerCredentials -Force
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

    Invoke-Command -Session $sessionId -Scriptblock {
    Install-WindowsFeature DHCP -IncludeManagementTools
    Add-DHCPServerInDC -DNSName PPS2022-SRV-DC.PPS2022.local
    Set-DHCPServerv4OptionValue -DNSServer 192.168.1.4 -DNSDomain PPS2022.local -Router 192.168.1.1
    Add-DHCPServerv4Scope -Name "Pool PPS2022" -StartRange 192.168.1.50 -EndRange 192.168.1.100 -SubnetMask 255.255.255.0 -Description "Plage DHCP pour projet PPS2022"
    }

    Remove-PSSession $sessionId
    Write-Host -Object "Le service DHCP a ete installe"
}

function DisplayMenu{
    $continue = $true
    while ($continue){
        write-host "----------SCRIPT INSTALLATION DES SERVICES -------------"
        write-host "1. Verifier WinRM sur le poste local"
        write-host "2. Installer le service Active Directory"
        write-host "3. Installer le service DHCP"
        write-host "x. Exit"
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
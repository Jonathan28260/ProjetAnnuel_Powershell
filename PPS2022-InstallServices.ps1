$ErrorActionPreference = "Continue"

function PPS2022TestWinRM{

    if(Get-Service -Name Winrm | Where-Object {$_.status -NotLike "Running"})
        {
            Start-Service WinRM
            Write-Host -Object "Le service WinRM a ete demarre" -ForegroundColor Yellow
        }

    else
        {
            Write-Host -Object "Le service WinRM est deja démarre" -ForegroundColor Green
        }

Read-Host "Appuyez sur ENTREE pour continuer..."

}

# New-PSSession -ComputerName pps2022-srv-dc-me5rkrxriayqw.switzerlandnorth.cloudapp.azure.com -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -Credential (Get-Credential)
function PPS2022InstallAD{
    #Recuperation des informations d'identification pour l'ordinateur cible
    $computerCredentials = Get-Credential -Message "Identifants de l'ordinateur distant"

    #Recuperation du SafePassword pour la foret ActiveDirectory
    $ADcredentials = Read-Host "Entrer le SafePassword pour la foret Active Directory :" -AsSecureString

    #Initialisation de la session Powershell à distance
    $computerName = Read-Host -Prompt "Veuillez entrer le nom du serveur auquel vous souhaiter accéder"
    $sessionId = New-PSSession -ComputerName $computerName -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -Credential $computerCredentials

    if($sessionId){
    Invoke-Command -Session $sessionId -ArgumentList $ADcredentials -Scriptblock {

        $verifAD = Get-ADDomainController
    
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
    $sessionId = New-PSSession -ComputerName $computerName -UseSSL -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck) -Credential $computerCredentials
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
        'x' {$continue = $false}
    default {Write-Host "Choix invalide"-ForegroundColor Red}
    }
    }
}

# DisplayMenu

function  TEST {
    Get-Alias -Name Test
    $Error[0].Exception.Message
}

DisplayMenu
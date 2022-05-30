# Installation Active Directory Windows server
# Prérequis paramétré via le template lors du déploiement du server : IP fixe, nom d'hôte, DNS

# Configuration de l'adresse IP de la machine, DHCP désactivé

function PPS2022-ConfigIp {
    New-NetIPAddress -InterfaceIndex 2 -IPAddress 192.128.1.10 -PrefixLength 24 -DefaultGateway 192.128.1.254

    Set-NetIPAddress -InterfaceIndex 2 -Dhcp Disabled

}

# Configuration DNS, paramétrage du suffixe DNS sur l'interface

function PPS2022-ConfigDNS {
    Set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses 192.128.1.10

    Set-DnsClient -InterfaceIndex 2 -ConnectionSpecificSuffix PPS2022.local
}

# Configuration nom d'hôte avec redémarrage

function PPS2022-CNH {
    Rename-Computer -NewName "PPS2022-PDC"
    Restart-Computer
}

# Optionnel : Changer la zone du pare-feu qui peut être en publique par défaut

function PPS2022-ParefeuDefaut {
    Set-NetConnectionProfile -Name "Réseau" -NetworkCategory Private
}

# Installation de l'AD

function PPS2022-InstallRole {
    Add-Windowsfeature -Name AD-Domaine-Serivces -IncludeManagementTools -IncludeAllSubFeature
    Add-Windowsfeature -Name DNS -IncludeManagementTools -IncludeAllSubFeature
}

# Installation outils d'administration

function PPS2022-OutilAD {
    Add-Windowsfeature -Name RSAT-AD-Tools -IncludeManagementTools -IncludeAllSubFeature

}

# Configuration du domaine

function PPS2022-ConfigDomain {
    $DomainName = "PPS2022.local"
    $DomainMode = "Default"
    $ForestMode = "Default"
    $InstallDNS = $true
    $DnsDelegation = $false
    $BiosName = "PPS2022"
    $Reboot = $false
    $SafePassword = "SciencesuMyges#!"
    $SafeAdministratorPassword = ConvertTo-SecureString $SafeModeClearPassword -AsPlaintext -Force
    $CheminNTDS = "C:\Windows\NTDS"
    $CheminLog = "C:\Windows\NTDS"
    $CheminSysvol = "C:\Windows\SYSVOL"


    Install-ADDSForest -CreateDnsDelegation:$DnsDelegation -DomainName $DomainName -DomainMode $DomainMode -DomaineNetbiosName $BiosName -ForestMode $ForestMode -InstallDNS:$InstallDNS -LogPath $CheminLog -NoRebootCompletion:$Reboot -SysvolPath $SysvolPath -SafeAdministratorPassword $SafeAdministratorPassword -Force:$true
    
}

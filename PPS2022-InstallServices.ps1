function PPS2022-TestWinRM{

    if(Get-Service -Name Winrm | ? {$_.status -NotLike "Running"})
        {
            Start-Service WinRM
            Write-Host -Object "Le service WinRM a été démarré"
        }

    else
        {
            Write-Host -Object "Le service WinRM est déja démarré"
        }

}


function PPS2022-InstallAD{
    $computerCredentials = Get-Credential -Message "Identifants de l'ordinateur"
    $ADcredentials = Get-Credential -Message "Identifiants pour SafePassword AD"
    $sessionId = New-PSSession -ComputerName 192.168.1.10 -Credential Administrateur
    Invoke-Command -Session $sessionId -ArgumentList $ADcredentials.Password -Scriptblock {
    $verifAD = Get-ADDomainController -ErrorAction SilentlyContinue
    
    if(!$verifAD)
    {
        #Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        Install-ADDSForest -DomainName "PPS2022.local" -DomainNetBiosName "PPS2022" -InstallDns:$true -NoRebootOnCompletion:$true -SafeModeAdministratorPassword $args[0] -Force
    }

    }

    Restart-Computer -ComputerName 192.168.1.10 -Wait -For PowerShell -Timeout 300 -Delay 2 -Credential $computerCredentials -Force
    Remove-PSSession $sessionId
    Write-Host -Object "Le serveur a redémarré"
}

function PPS2022-InstallDHCP{

    $sessionId = New-PSSession -ComputerName 192.168.1.10 -Credential Administrateur
    Invoke-Command -Session $sessionId -Scriptblock {
    Install-WindowsFeature DHCP -IncludeManagementTools
    Add-DHCPServerInDC -DNSName SRV-AD.PPS2022.local
    Set-DHCPServerv4OptionValue -DNSServer 192.168.1.10 -DNSDomain PPS2022.local -Router 192.168.1.1
    Add-DHCPServerv4Scope -Name "Pool PPS2022" -StartRange 192.168.1.50 -EndRange 192.168.1.100 -SubnetMask 255.255.255.0 -Description "Plage DHCP pour projet PPS2022"
    }

    Remove-PSSession $sessionId
    Write-Host -Object "Le service DHCP a été installé"

}

function PPS2022-InstallIIS{

    $sessionId = New-PSSession -ComputerName 192.168.1.10 -Credential "PPS2022\Administrateur"
    Invoke-Command -Session $sessionId -Scriptblock {
    
    #Installer IIS et les composants
    Install-WindowsFeature web-server -IncludeManagementTools
    Install-windowsfeature web-mgmt-service
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1
    install-windowsfeature Web-Asp-Net45  
    install-windowsfeature Web-ISAPI-Ext
    install-windowsfeature web-windows-auth
    Net Stop WMSVC
    Net Start WMSVC
    }



}

PPS2022-InstallAD
#PPS2022-InstallDHCP
#PPS2022-InstallIIS



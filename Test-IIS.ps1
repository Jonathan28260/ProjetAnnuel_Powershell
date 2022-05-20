function PPS2022-InstallIIS{

    $sessionId = New-PSSession -ComputerName "PPS2022-SRV-IIS" -Credential "PPS2022\Administrateur"
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
PPS2022-InstallIIS

function PPS2022installIIS{

    #Installer IIS et les composants
    Install-WindowsFeature web-server -IncludeManagementTools
    Install-windowsfeature web-mgmt-service
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1
    install-windowsfeature Web-Asp-Net45  
    install-windowsfeature Web-ISAPI-Ext
    install-windowsfeature web-windows-auth
    Net Stop WMSVC
    Net Start WMSVC
    New-NetFirewallRule -Name "IIS80" -DisplayName "IIS80" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 80 -Protocol TCP
    }
PPS2022installIIS

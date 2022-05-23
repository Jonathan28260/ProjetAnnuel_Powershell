param(
$DomainPassword
)

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

# function JoinDomain{

#     #Ajout du DC en DNS pour rejoindre le domaine#
#     Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "192.168.1.10"
#     #netsh interface ip set dns "Ethernet" static 192.168.1.10

#     #Joindre le domaine#
#     Add-Computer -DomainName PPS2022.local -DomainCredential administrateur@PPS2022.local -Password $DomainPassword

# }
# JoinDomain

function ScheduledTask{

    New-item -Path "C:\" -Name "Scripts" -ItemType "directory"
    ADD-content -path "C:\Scripts\PPS2022-Loop-Supervision.ps1" -value "while($true){ C:\Scripts\PPS2022-Supervision.ps1 
    sleep -seconds 10 }"
    ADD-content -path "C:\Scripts\NomsServeurs.txt" -value "PPS2022-SRV-DC
    PPS2022-SRV-IIS"
    cd C:\Scripts
    Invoke-WebRequest -Uri "https://github.com/Jonathan28260/ProjetAnnuel_Powershell/blob/main/PPS2022-Supervision.ps1" 

    $action=New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass C:\Scripts\PPS2022-Loop-Supervision.ps1"
    $trigger=New-ScheduledTaskTrigger -Once -AtStartup
    Register-ScheduledTask -TaskName "Supervision" -Trigger $trigger -Action $action -Description "Supervision" -User "PPS2022\Administrateur"

    }
ScheduledTask    

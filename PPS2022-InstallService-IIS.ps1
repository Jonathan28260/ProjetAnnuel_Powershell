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

function PPS2022ScheduledTask{

    New-item -Path "C:\" -Name "Scripts" -ItemType "directory"
    ADD-content -path "C:\Scripts\PPS2022-Loop-Supervision.ps1" -value 'while($true){ C:\Scripts\PPS2022-Supervision.ps1 
    sleep -seconds 10 }'
    ADD-content -path "C:\Scripts\NomsServeurs.txt" -value "PPS2022-SRV-DC`nPPS2022-SRV-IIS"
    cd C:\Scripts
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Jonathan28260/ProjetAnnuel_Powershell/main/PPS2022-Supervision.ps1" -OutFile C:\Scripts\PPS2022-Supervision.ps1 
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File "C:\Scripts\PPS2022-Loop-Supervision.ps1"'
    $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
    $principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
    $definition = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Description "Run $($taskName) at startup"
    Register-ScheduledTask -TaskName "Supervision" -InputObject $definition
    
    }
PPS2022ScheduledTask    

Start-Sleep -s 300

function JoinDomain{

    #Ajout du DC en DNS pour rejoindre le domaine#
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "192.168.1.10"
   
    #Joindre le domaine#
    $Domain = "PPS2022.local"
    $username = "PPS2022\Administrateur"
    $Password = ConvertTo-SecureString $DomainPassword  -AsPlainText  -Force 
    $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
    Add-Computer -DomainName $Domain -Credential $credential
    Restart-Computer -Force

}
JoinDomain

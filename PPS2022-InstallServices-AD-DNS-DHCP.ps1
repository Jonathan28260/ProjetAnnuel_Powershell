param
(
$ADPassword
)

function PPS2022InstallAD{

        $SafeModeAdministratorPassword= ConvertTo-SecureString $ADPassword  -AsPlainText  -Force
        Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        Install-ADDSForest -DomainName "PPS2022.local" -DomainNetBiosName "PPS2022" -InstallDns:$true -NoRebootOnCompletion:$true -SafeModeAdministratorPassword $SafeModeAdministratorPassword -Force        
        
}
PPS2022InstallAD

function PPS2022ScheduledTask{

    New-item -Path "C:\" -Name "Scripts" -ItemType "directory"
    cd C:\Scripts
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Jonathan28260/ProjetAnnuel_Powershell/main/PPS2022-CreationUoUtilisateurs.ps1" -OutFile C:\Scripts\PPS2022-CreationUoUtilisateurs.ps1
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Jonathan28260/ProjetAnnuel_Powershell/main/NouveauxUtilisateurs.csv" -OutFile C:\Scripts\NouveauxUtilisateurs.csv
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File "PPS2022-CreationUoUtilisateurs.ps1"'
    $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
    $principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
    $definition = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Description "Run $($taskName) at startup"
    Register-ScheduledTask -TaskName $taskName -InputObject $definition

    }
PPS2022ScheduledTask    

function PPS2022InstallDHCP{
      
    Install-WindowsFeature DHCP -IncludeManagementTools
    Add-DHCPServerInDC -DNSName SRV-AD.PPS2022.local
    Set-DHCPServerv4OptionValue -DNSServer 192.168.1.10 -DNSDomain PPS2022.local -Router 192.168.1.1
    Add-DHCPServerv4Scope -Name "Pool PPS2022" -StartRange 192.168.1.50 -EndRange 192.168.1.100 -SubnetMask 255.255.255.0 -Description "Plage DHCP pour projet PPS2022"
    Restart-Computer -Force
}
PPS2022InstallDHCP

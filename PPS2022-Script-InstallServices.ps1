
function PPS2022InstallAD{

        Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        Install-ADDSForest -DomainName "PPS2022.local" -DomainNetBiosName "PPS2022" -InstallDns:$true -NoRebootOnCompletion:$true -SafeModeAdministratorPassword  -Force
        Restart-Computer
}
PPS2022InstallAD

function PPS2022InstallDHCP{
      
    Install-WindowsFeature DHCP -IncludeManagementTools
    Add-DHCPServerInDC -DNSName SRV-AD.PPS2022.local
    Set-DHCPServerv4OptionValue -DNSServer 192.168.1.10 -DNSDomain PPS2022.local -Router 192.168.1.1
    Add-DHCPServerv4Scope -Name "Pool PPS2022" -StartRange 192.168.1.50 -EndRange 192.168.1.100 -SubnetMask 255.255.255.0 -Description "Plage DHCP pour projet PPS2022"
    
}
PPS2022InstallDHCP

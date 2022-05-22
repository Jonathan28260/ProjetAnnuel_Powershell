
function PPS2022InstallAD{
    
    $verifAD = Get-ADDomainController -ErrorAction SilentlyContinue
    
    if(!$verifAD)
    {
        #Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        Install-ADDSForest -DomainName "PPS2022.local" -DomainNetBiosName "PPS2022" -InstallDns:$true -NoRebootOnCompletion:$true -SafeModeAdministratorPassword  -Force
    }
    Restart-Computer
}




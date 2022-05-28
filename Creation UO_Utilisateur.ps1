# Configuration / Paramétrage AD

function PPS2022CreationUO {

    $sessionId = New-PSSession -ComputerName pps2022testdc.switzerlandnorth.cloudapp.azure.com -Credential PPS2022\Administrateur
    Invoke-Command -Session $sessionId -Scriptblock {

    New-ADOrganizationalUnit "Direction" -Path "DC=PPS2022,DC=local"
    New-ADGroup -Name "Direction Users" -GroupScope Global -Path "OU=Direction,DC=PPS2022,DC=local"

    New-ADOrganizationalUnit "Marketing" -Path "DC=PPS2022,DC=local"
    New-ADGroup -Name "Marketing Users" -GroupScope Global -Path "OU=Marketing,DC=PPS2022,DC=local"

    New-ADOrganizationalUnit "Comptabilite" -Path "DC=PPS2022,DC=local"
    New-ADGroup -Name "Compta Users" -GroupScope Global -Path "OU=Comptabilite,DC=PPS2022,DC=local"
    }
}

# Paramétrage comptes utilisateurs

<#
function PPS2022CreationUser {
    New-ADUser -Name "Direction PPS2022" -GivenName "Direction" -Surname "PPS2022" -SamAccountName "direction" -UserPrincipalName "dpps2022@PPS2022.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "direction" -Force) -Enbale $true -ChangePasswordAtLogon $false -Path "OU=Direction,OU=Compta,OU=Marketing,DC=PPS2022,DC=local"
}
#>

# Ci-joint le chemin d'accès vers le fichier d'importation CSV

$UtilisateurAD = Import-csv .\NouveauxUtilisateurs.CSV -Delimiter ";"

function PPS2022CreationUtilisateurs{

    $sessionId = New-PSSession -ComputerName pps2022testdc.switzerlandnorth.cloudapp.azure.com -Credential PPS2022\Administrateur
    $commande = Invoke-Command -Session $sessionId -ArgumentList $UtilisateurAD -Scriptblock {

        foreach ($Utilisateur in $args[0])
        {

            $Username    = $Utilisateur.identifiant
            $Password    = $Utilisateur.motdepasse
            $Firstname   = $Utilisateur.prenom
            $Lastname    = $Utilisateur.nom
            $OU          = $Utilisateur.ou

            # Nous allons vérifier si l'utilisateur existe déjà et renvoyer un message dans le cas ou il existe
            # S'il n'existe pas il sera créé
            # Le compte sera créé dans I’unité d’organisation indiquée dans la variable $OU du fichier CSV 

            if (Get-ADUser -F {SamAccountName -eq $Username})
            {
                Write-Warning "L'utilisateur $Username existe déjà dans l'Active Directory."
            }
            else
            {
                New-ADUser `
                -SamAccountName $Username `
                -UserPrincipalName "$Username@PPS2022.local" `
                -Name "$Firstname $Lastname" `
                -GivenName $Firstname `
                -Surname $Lastname `
                -Enabled $True `
                -ChangePasswordAtLogon $True `
                -DisplayName "$Lastname, $Firstname" `
                -Path "OU=$OU,DC=PPS2022,DC=local" `
                -AccountPassword (convertto-securestring $Password -AsPlainText -Force)

       }
    }
    }

    return $commande
}

# PPS2022CreationUO
# PPS2022CreationUtilisateurs

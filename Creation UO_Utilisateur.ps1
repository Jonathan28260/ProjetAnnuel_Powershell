# Configuration / Paramétrage AD

function PPS2022CreationUO {
    New-ADOrganizationalUnit "Direction" -Path "OU=DC=PPS2022,DC=local"
    New-ADGroup -Name "Direction Users" -GroupeScope Global -Path "OU=Direction,DC=PPS2022,DC=local"

    New-ADOrganizationalUnit "Marketing" -Path "OU=DC=PPS2022,DC=local"
    New-ADGroup -Name "Marketing Users" -GroupeScope Global -Path "OU=Marketing,DC=PPS2022,DC=local"

    New-ADOrganizationalUnit "Compta" -Path "OU=DC=PPS2022,DC=local"
    New-ADGroup -Name "Compta Users" -GroupeScope Global -Path "OU=Compta,DC=PPS2022,DC=local"
}

# Paramétrage comptes utilisateurs

<#
function PPS2022CreationUser {
    New-ADUser -Name "Direction PPS2022" -GivenName "Direction" -Surname "PPS2022" -SamAccountName "direction" -UserPrincipalName "dpps2022@PPS2022.local" -AccountPassword (ConvertTo-SecureString -AsPlainText "direction" -Force) -Enbale $true -ChangePasswordAtLogon $false -Path "OU=Direction,OU=Compta,OU=Marketing,DC=PPS2022,DC=local"
}
#>

# Ci-joint le chemin d'accès vers le fichier d'importation CSV

$UtilisateurAD = Import-csv C:\Users\scripts\NouveauxUtilisateurs.CSV


foreach ($Utilisateur in $UtilisateurAD)
{

       $Username    = $Utilisateur.identifiant
       $Password    = $Utilisateur.motdepasse
       $Firstname   = $Utilisateur.prenom
       $Lastname    = $Utilisateur.nom
       $Department = $Utilisateur.departement
       $OU           = $Utilisateur.ou

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
            -Department $Department `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)

       }
}
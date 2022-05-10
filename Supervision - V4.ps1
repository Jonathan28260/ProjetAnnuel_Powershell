


#Le fichier d'entrée avec les noms des windows core
$NomsServeurs = Get-Content 'C:\Users\B0003296\OneDrive - Groupe BPCE\Documents\PowerShell\Script Supervision\NomsServeurs.txt'

#Le fichier HTML de sortie qui sera la page web de supervision
$HTMLSupervision = 'C:\Users\B0003296\OneDrive - Groupe BPCE\Documents\PowerShell\Script Supervision\HTMLSupervision.html'

#Ajout du module w3 css et réglages de la barre superieur du tableau HTML
'<body class="w3-tiny">
<div class="w3-responsive "w3-tiny"">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<h4 class="w3-indigo w3-center">Resultats du '+(Get-date -Format "dd/MM/yyyy HH:mm")+'</h4>
<table class="w3-table w3-centered w3-bordered w3-card-4 w3-centered w3-hoverable">
<tr class="w3-indigo">
    <th class="w3-border w3-tiny">Nom du serveur</th>
    <th class="w3-border w3-tiny">Adresse(s) IP</th>
    <th class="w3-border w3-tiny">Version de Windows</th>
    <th class="w3-border w3-tiny">Numero de build</th>
    <th class="w3-border w3-tiny">Utilisation CPU</th>
    <th class="w3-border w3-tiny">Utilisation RAM</th>
    <th class="w3-border w3-tiny">Statut</th>
' | Out-File $HTMLSupervision utf8
#fin des réglages



#To do : idéee pourquoi pas faire ligne de la couleur vert ou rouge etc suivant l'usage cpu, ram etc ça serait visuel et cool
#        La partie warning marche pas en l'état.

function Supervision
{
    foreach($Nom in $NomsServeurs)
    {
        "<tr class=><td class" +$ColorStatut +">"+ $Nom +"</td>" | Out-File $HTMLSupervision -Append utf8
        AdresseIP
        OSInformation
        CPUUsage
        RAMUsage
        Statut
    }
}


function AdresseIP #Le but de cette fonction est de connaitre l'IP en connaissant le nom DNS
{
    $IP = (Resolve-DNSName $Nom -Type A).IPAddress -join " - " #Resolution DNS pour avoir IP, separation de multiresultats par un tiret
    "<td class=" +$ColorStatut +">" + $IP +"</td>" | Out-File $HTMLSupervision -Append utf8 #J'ajoute ma variable IP au HTML
}


function OSInformation
{
    $OSVersion = (Get-WmiObject Win32_OperatingSystem -ComputerName $Nom).Caption #Commande pour connaitre la version de l'OS
    $OSBuild = (Get-WmiObject Win32_OperatingSystem -ComputerName $Nom).BuildNumber #Commande pour connaitre le numero de build de l'OS
    "<td class=" +$ColorStatut +">" + $OSVersion +"</td>" | Out-File $HTMLSupervision -Append utf8 #J'ajoute la variable OSVersion au HTML
    "<td class=" +$ColorStatut +">" + $OSBuild +"</td>" | Out-File $HTMLSupervision -Append utf8 #J'ajoute la variable OSBuild au HTML
}


function CPUUsage
{
    $CPUUsage = (Get-WmiObject -ComputerName $Nom -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average #Commande pour avoir l'usage du CPU en pourcents
    if ($CPUUsage -le 70) # Si l'usage CPU est en dessous de 70%
    {
        $ColorCPU = 'w3-green' #La variable ColorCPU prend la valeur vert
    }

    elseif(($CPUUsage -gt 70) -and ($CPUUsage -le 85)) #Sinon si l'usage CPU est entre  de 70% et 85%
    {
        $ColorCPU = 'w3-yellow' #La variable ColorCPU prend la valeur jaune
    }

    else #Sinon
    {
        $ColorCPU = 'w3-red'#La variable ColorCPU prend la valeur rouge
    }

    "<td class=" +$ColorCPU +">" + $CPUUsage + " %" +"</td>" | Out-File $HTMLSupervision -Append utf8 #J'ajoute la variable Usage CPU au HTML avec la couleur en fonction de l'usage CPU
}


function RAMUsage
{
    $RAMInfos =  Get-WmiObject -Class WIN32_OperatingSystem -ComputerName $Nom  #Je recupere les informations hardware
    $RAMUsage = [math]::round((($RAMInfos.TotalVisibleMemorySize - $RAMInfos.FreePhysicalMemory)*100)/ $RAMInfos.TotalVisibleMemorySize) #math pour limiter les decimales; Ensuite calcul entre la ram utilisé et la ram totale pour avoir un pourcentage d'utilisation
    
    if ($RAMUsage -le 70) # Si l'usage RAM est en dessous de 70%
    {
        $ColorRAM= 'w3-green' #La variable ColorRAM prend la valeur vert
    }

    elseif(($RAMUsage -gt 70) -and ($RAMUsage -le 85)) #Sinon si l'usage RAM est entre  de 70% et 85%
    {
        $ColorRAM = 'w3-yellow' #La variable ColorRAM prend la valeur jaune
    }

    else #Sinon
    {
        $ColorRAM = 'w3-red'#La variable ColorRAM prend la valeur rouge
    }
    
    "<td class=" +$ColorRAM +">" + $RAMUsage + " %" +"</td>" | Out-File $HTMLSupervision -Append utf8 #J'ajoute la variable RAMUsage au HTML avec la couleur qui va bien
}


function statut
{
    if(($ColorCPU -eq 'w3-green') -and ($ColorRAM -eq 'w3-green')) #Si la RAM et le CPU sont au vert
    {
        $Statut = 'Good' #La variable statut vaut "Good"
        $ColorStatut = 'w3-light-green' #La variable ColorStatut sera verte
    }

    elseif(($ColorCPU -eq 'w3-red') -and ($ColorRAM -eq 'w3-red')) #Sinon si la RAM et le CPU sont au rouge
    {
        $Statut = 'KO' #La variable statut vaut "KO"
        $ColorStatut = 'w3-pale-red' #La variable ColorStatut sera rouge
    }

    else #Sinon
    {
        $Statut = 'Warning' #La variable statut vaut "Warning"
        $ColorStatut = 'w3-pale-yellow' #La variable ColorStatut sera jaune
    }

    "<td class=" +$ColorStatut +">" + $Statut +"</td>" | Out-File $HTMLSupervision -Append utf8 #J'ajoute la variable Statut au HTML avec la couleur qui va bien

}
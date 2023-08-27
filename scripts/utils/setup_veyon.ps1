function AddPath
{
  param ([string] $pathToAdd)

  $regexAddPath = [regex]::Escape($pathToAdd)
  $arrPath = $env:Path -split ";" | Where-Object {$_ -notmatch "^$regexAddPath\\?"}
  $env:Path = ($arrPath + $pathToAdd) -join ";"
}

$cred = Get-Credential -Credential winadmin
New-PSDrive -Name "H" -Root "\\172.16.0.253\winadmin" -PSProvider "FileSystem" -Credential $cred

$ListesPC = "\\172.16.0.253\winadmin\DOCUMENTS_TICE\Ressources\Veyon\Salles"

$ClassrommToSetup = ""

Write-Host @"
  Pour quelle salle voulez-vous configurer Veyon Master ?
  1 - Salle Multimedia
  2 - CDI
  3 - Salle Pupitre RDC
  4 - Salle Bleue
  5 - Salle Techno 1
  6 - Salle Techno 2
"@

$choix = Read-Host "Votre choix : "

switch($choix)
{
  1
  {
    $ClassrommToSetup = "Multimedia"
  }
  2
  {
    $ClassrommToSetup = "CDI"
  }
  3
  {
    $ClassrommToSetup = "PupitreRDC"
  }
  4
  {
    $ClassrommToSetup = "Bleue"
  }
  5
  {
    $ClassrommToSetup = "Techno1"
  }
  6
  {
    $ClassrommToSetup = "Techno2"
  }
}

AddPath("$env:ProgramFiles\Veyon")
veyon-cli networkobjects import $(Join-Path -Path $ListesPC -ChildPath "$ClassrommToSetup.csv") format "%location% %name% %host% %mac%"

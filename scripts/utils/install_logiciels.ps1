param ([switch]$InstallPronote)

$WorkFolder = Join-Path -Path $HOME -ChildPath "poste-setup" | Join-Path -ChildPath "poste-setup-main"

function InstallerLogicielsWinget
{
  $listeLogiciels = @(
    "Mozilla.Firefox.ESR"
    "Google.Chrome"
    "7zip.7zip"
    "VideoLAN.VLC"
    "Audacity.Audacity"
    "Meltytech.Shotcut"
    "Oracle.JavaRuntimeEnvironment"
    "Google.EarthPro"
    "TheDocumentFoundation.LibreOffice"
    "Notepad++.Notepad++"
    "DuongDieuPhap.ImageGlass"
    "VeyonSolutions.Veyon"
    "ArduinoSA.IDE.stable"
    "Freeplane.Freeplane"
    "eTeks.SweetHome3D"
    "GeoGebra.Classic"
    "MITMediaLab.Scratch.3"
  )

  foreach($logiciel in $listeLogiciels)
  {
    winget install -e --id $logiciel --scope machine | Out-Null
  }

  winget install -e --id makeblockteam.mBlock | Out-Null
}

function InstallerPronote
{
  $LienPronote = "https://tele3.index-education.com/telechargement/pn/v2023.0/exe/Install_PRNclient_FR_2023.0.2.1_win64.exe"
  $tempFolder = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "Pronote"
  $tempFile = Join-Path -Path $tempFolder -ChildPath "Pronote2023.exe"

  if(-not (Test-Path $tempFolder))
  {
    New-Item -ItemType Directory -Path $tempFolder
  }

  Invoke-WebRequest $LienPronote -OutFile $tempFile

  Start-Process -FilePath $tempFile  
}

function AppliquerPolitiqueSecurite
{
  $DossierPolitiqueSecu = Join-Path -Path $WorkFolder -ChildPath "assets"
  $PolitiquesSecu = Get-ChildItem -Path $DossierPolitiqueSecu

  foreach($file in $PolitiquesSecu)
  {
    reg import $file.FullName
  }
}

InstallerLogicielsWinget
AppliquerPolitiqueSecurite

if($InstallPronote)
{
  InstallerPronote
}

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
  )

  foreach($logiciel in $listeLogiciels)
  {
    winget install -e --id $logiciel --scope machine
  }
}

function InstallerPronote
{
  $LienPronote = "https://tele3.index-education.com/telechargement/pn/v2023.0/exe/Install_PRNclient_FR_2023.0.2.1_win64.exe"
  $Webclient = New-Object System.Net.WebClient

  $tempFolder = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "Pronote"
  $tempFile = Join-Path -Path $tempFolder -ChildPath "PronoteInstaller.exe" 

  try
  {
    $Webclient.DownloadFile($LienPronote,$tempFile)
  } catch
  {
    throw [System.Net.WebException]::new("Erreur du téléchargement : ", $_.Exception)
  }
}

InstallerPronote

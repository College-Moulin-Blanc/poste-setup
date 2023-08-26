$GithubRepositoryUri = "https://github.com/College-Moulin-Blanc/poste-setup/archive/refs/heads/main.zip"

$PosteSetupFolder = Join-Path $HOME -ChildPath "poste-setup"
$ZipFile = Join-Path -Path $PosteSetupFolder -ChildPath "poste-setup-main.zip"
$WorkFolder = Join-Path -Path $PosteSetupFolder -ChildPath "poste-setup-main" | Join-Path -ChildPath "scripts"

$DownloadResult = $false

if(Test-Path $PosteSetupFolder)
{
  Remove-Item -Path $PosteSetupFolder -Recurse -Force
}
New-Item $PosteSetupFolder -ItemType Directory

try
{
  Invoke-WebRequest $GithubRepositoryUri -O $ZipFile
  $DownloadResult = $true
} catch [System.Net.WebException]
{
  Write-Host "Erreur de connexion à Github, vérifiez la connexion internet or l'URL du depot" -ForegroundColor Red
}

if($DownloadResult)
{
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile,$PosteSetupFolder)
  Invoke-Expression (Join-Path -Path $WorkFolder -ChildPath "install.ps1")
}

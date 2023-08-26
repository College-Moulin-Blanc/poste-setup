$PosteSetupFolder = Join-Path $HOME -ChildPath "poste-setup"
$WorkFolder = Join-Path -Path $PosteSetupFolder -ChildPath "poste-setup-main" | Join-Path -ChildPath "scripts"

Invoke-Expression (Join-Path -Path $WorkFolder -ChildPath "install_winget.ps1")

if($env:COMPUTERNAME -notmatch "prof")
{
  Invoke-Expression (Join-Path -Path $WorkFolder -ChildPath "install_logiciels.ps1")
} else
{
  Invoke-Expression (Join-Path -Path $WorkFolder -ChildPath "install_logiciels.ps1") -InstallPronote
}

$PosteSetupFolder = Join-Path $HOME -ChildPath "poste-setup"
$WorkFolder = Join-Path -Path $PosteSetupFolder -ChildPath "poste-setup-main" | Join-Path -ChildPath "scripts" | Join-Path -ChildPath "utils"

Invoke-Expression (Join-Path -Path $WorkFolder -ChildPath "install_winget.ps1")
Invoke-Expression (Join-Path -Path $WorkFolder -ChildPath "install_logiciels.ps1")

Remove-Item -Recurse -Force $PosteSetupFolder

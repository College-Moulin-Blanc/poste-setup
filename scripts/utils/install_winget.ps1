# Ce script permet d'installer les logiciels sur un poste à partir de 0

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Webclient = New-Object System.Net.WebClient

function GetLatestWingetRelease
{
  $releasesApiResponse = Invoke-RestMethod "https://api.github.com/repos/microsoft/winget-cli/releases?per_page=100"
  $releasesApiResponse = $releasesApiResponse.Where({ !$_.prerelease}) | Sort-Object -Property published_at -Descending

  $assets = $releasesApiResponse[0].assets

  $shaFileUrl = $assets.Where({$_.Name -eq "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.txt"}).browser_download_url
  $shaFile = New-TemporaryFile
  $Webclient.DownloadFile($shaFileUrl,$shaFile.FullName)

  return @{
    shaFileUrl = $assets.Where({$_.Name -eq "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.txt"}).browser_download_url
    msixFileUrl = $assets.Where({$_.Name -eq "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"}).browser_download_url
    releaseTag = $releasesApiResponse[0].tag_name
    shaFileContent = $(Get-Content $shaFile.FullName)
  }
}

function InstallWinget
{
  $tempFolder = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "Winget"

  $latestRelease = GetLatestWingetRelease
  $desktopAppInstaller = @{
    url = $latestRelease.msixFileUrl
    hash = $latestRelease.shaFileContent
    SaveTo = $(Join-Path $env:LOCALAPPDATA -ChildPath "Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\bin\$($latestRelease.releaseTag)\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
  }

  $vcLibsUwp = @{
    url = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    hash = "9BFDE6CFCC530EF073AB4BC9C4817575F63BE1251DD75AAA58CB89299697A569"
    SaveTo = $(Join-Path $tempFolder -ChildPath "Microsoft.VCLibs.x64.14.00.Desktop.appx")
  }

  $uiLibsUwp = @{
    url = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx"
    hash = "8CE30D92ABEC6522BEB2544E7B716983F5CBA50751B580D89A36048BF4D90316"
    SaveTo = $(Join-Path $tempFolder -ChildPath "Microsoft.UI.Xaml.2.7.x64.appx")
  }

  $dependencies = @($desktopAppInstaller, $vcLibsUwp, $uiLibsUwp)

  Get-ChildItem $tempFolder -Recurse -Exclude $($(Split-Path $dependencies.SaveTo -Leaf) -replace "\.([^\.]+)$",".*") | Remove-Item -Force -Recurse

  foreach($dependency in $dependencies)
  {
    if(-not ((Test-Path -Path $dependency.SaveTo) -and $dependency.hash -eq $(Get-FileHash $dependency.SaveTo).Hash))
    {
      Write-Host @"
        - Téléchargement : $($dependency.url)
"@

      try
      {
        $saveDirectory = Split-Path $dependency.SaveTo
        if(-not (Test-Path -Path $saveDirectory))
        {
          New-Item -ItemType Directory -Path $saveDirectory -Force | Out-Null
        }
        $Webclient.DownloadFile($dependency.url, $dependency.SaveTo)
      } catch
      {
        throw [System.Net.WebException]::new("Erreur de téléchargement pour $($dependency.url) : ", $_.Exception)
      }
      if (-not ($dependency.hash -eq $(Get-FileHash $dependency.SaveTo).Hash))
      {
        throw [System.Activities.VersionMismatchException]::new("Le hash de la dépendance ne correspond pas avec le fichier téléchargé")        
      }

      Add-AppxPackage -Path "$($desktopAppInstaller.SaveTo)" -DependencyPath "$($vcLibsUwp.SaveTo),$($uiLibsUwp.SaveTo)"
    }
  }

}

InstallWinget

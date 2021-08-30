Enable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -All
$PSVersionTable.PSVersion
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

$url = "https://download.visualstudio.microsoft.com/download/pr/e730a0bd-baf1-4f4c-9341-ca5a9caf0f9f/4358b712148b3781631ab8d0eea42af736398c8b44fba868b76cb255b3de7e7c/vs_Professional.exe"
New-Item -Path 'C:\dev\pub\vs' -ItemType Directory -force

$downloadPath = "C:\dev\pub\vs"
$filePath = "C:\dev\pub\vs\vs_professional.exe"
Invoke-WebRequest -URI $url -OutFile $filePath

$workloadArgument = @(
   
    '--add Microsoft.Net.Component.4.7.1.SDK'

    '--add Microsoft.VisualStudio.Component.Windows10SDK.17134'

    '--add Microsoft.Net.Component.4.7.1.TargetingPack'
) 

$optionsAddLayout          = [string]::Join(" ", $workloadArgument )
$optionsQuiet              = "--quiet"
$optionsLayout             = "--layout $downloadPath"
$optionsIncludeRecommended = "--includeRecommended"

$vsOptions = @(
    $optionsLayout,
    $optionsIncludeRecommended,
    $optionsAddLayout
    $optionsQuiet
)

#Start-Process -FilePath $filePath -ArgumentList $vsOptions
Start-Process -Wait -FilePath $filePath -ArgumentList "/S /v /qn" -passthru

#
# Reference: https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/iis/?view=aspnetcore-3.1
#
# Quick way to download the Windows Hosting Bundle and Web Deploy installers which may
# then be executed on the VM ...
#

#
# Set path where installer files will be downloaded ...
#
New-Item -Path 'C:\temp\' -ItemType Directory -force
$temp_path = "C:\temp\"

if( ![System.IO.Directory]::Exists( $temp_path ) )
{

   Write-Output "Path not found ($temp_path), create the directory and try again"

   Break

}


#
# Download the Windows Hosting Bundle Installer for ASP.NET Core 3.1 Runtime (v3.1.0)
#
# The installer URL was obtained from:
# https://dotnet.microsoft.com/download/dotnet-core/thank-you/runtime-aspnetcore-3.1.0-windows-hosting-bundle-installer
#

$whb_installer_url = "https://download.visualstudio.microsoft.com/download/pr/fa3f472e-f47f-4ef5-8242-d3438dd59b42/9b2d9d4eecb33fe98060fd2a2cb01dcd/dotnet-hosting-3.1.0-win.exe"

$whb_installer_file = $temp_path + [System.IO.Path]::GetFileName( $whb_installer_url )

Try
{

   Invoke-WebRequest -Uri $whb_installer_url -OutFile $whb_installer_file

   Write-Output ""
   Write-Output "Windows Hosting Bundle Installer downloaded"
   Write-Output "- Execute the $whb_installer_file to install the ASP.Net Core Runtime"
   Write-Output ""
   $pathvargs = {C:\temp\dotnet-hosting-3.1.0-win /S /v/qn }
    Invoke-Command -ScriptBlock $pathvargs

}
Catch
{

   Write-Output ( $_.Exception.ToString() )

   Break

}

echo "Merged branches"
for branch in `git branch -r --merged | grep -v HEAD`;do echo -e `git log --no-merges -n 1 --format="%ci, %cr, %an, %ae, "  $branch | head -n 1` \\t$branch; done | sort -r

echo ""
echo "Not merged branches"
for branch in `git branch -r --no-merged | grep -v HEAD`;do echo -e `git log --no-merges -n 1 --format="%ci, %cr, %an, %ae, " $branch | head -n 1` \\t$branch; done | sort -r


Enable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -All
$PSVersionTable.PSVersion
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force


#.net 4.8 install..
$username = "any"
$password = "any"
 
Start-BitsTransfer -Source 'https://go.microsoft.com/fwlink/?linkid=2088631'  -Destination "$Env:Temp\Net4.8.exe";
$i = 0
do {
    $file = Test-Path $Env:Temp\Net4.8.exe
        if ($file -eq $False)  {$i = 0}
  
        elseif ($file -eq $True)
            {
                Write-Host " THE exe  does exist "
                Start-Process $Env:Temp\Net4.8.exe /q
                $i++
            }   
   }
until ($i -eq 1)


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

param (
  $Destination = $(New-Item -Path 'C:\dev\pub\vs' -ItemType Directory -force),
  # Use $(...) to use a command's output as a parameter default value.
  # By contrast assigning "..." only assigns a *string*.
  $session = $(New-PSSession -ComputerName $server -Credential $mycredentials),
  # To be safe, better to `-escape $ inside "..." if it's meant to be a literal.
  $SourceFile = ("https://download.visualstudio.microsoft.com/download/pr/e730a0bd-baf1-4f4c-9341-ca5a9caf0f9f/4358b712148b3781631ab8d0eea42af736398c8b44fba868b76cb255b3de7e7c/vs_Professional.exe")
  
)

Write-Host "Installing Visual Studio"

Copy-Item -FromSession $session -Path $SourceFile -Destination $destination -Force

# You don't need the session anymore now that you've copied the file.
# Normally you'd call
#     Remove-PSSession $session
# However, given that the session may have been passed as an argument, the caller
# may still need it.

# With the installer present on the local machine, you can invoke
# Start-Process locally - no need for a session.
Start-Process -Wait $Destination\vs_Professional.exe -ArgumentList '--quiet', '--installPath "C:\VS"'

# No need for Exit-PSSession (which is a no-op here), given that 
# you haven't used Enter-PSSession.

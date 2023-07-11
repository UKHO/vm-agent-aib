Write-Host "Setup PowerShellGet"
# Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowerShellGet -Force
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery

Write-Host "Install chocolatey"
$chocoExePath = 'C:\ProgramData\Chocolatey\bin'

if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower())) {
    Write-Host "Chocolatey found in PATH, skipping install..."
    Exit
}

# Add to system PATH
$systemPath = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
$systemPath += ';' + $chocoExePath
[Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine)

# Update local process' path
$userPath = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::User)
if ($userPath) {
    $env:Path = $systemPath + ";" + $userPath
}
else {
    $env:Path = $systemPath
}

# Run the installer
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# Turn off confirmation
choco feature enable -n allowGlobalConfirmation

# https://github.com/chocolatey/choco/issues/89
# Remove some of the command aliases, like `cpack` #89
Remove-Item -Path $env:ChocolateyInstall\bin\cpack.exe -Force
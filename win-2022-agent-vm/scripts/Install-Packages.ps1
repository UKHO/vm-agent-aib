
################################################################################
##  File:  Install-Oackages.ps1
##  Desc:  Install Chocolatey Packages.
################################################################################

Write-Host "Installing Using Chocolatey."
choco install powershell-core

Write-Host "Install Python"

choco install python311

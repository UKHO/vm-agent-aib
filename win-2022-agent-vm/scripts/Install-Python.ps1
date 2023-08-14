
################################################################################
##  File:  Install-Oackages.ps1
##  Desc:  Install Chocolatey Packages.
################################################################################

Write-Host "Install Python"
choco install python311 --params "InstallAllUsers=1 PrependPath=1 Include_test=0"

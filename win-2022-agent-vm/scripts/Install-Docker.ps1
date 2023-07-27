################################################################################
##  File:  Install-Docker.ps1
##  Desc:  Install Docker.
##         Must be an independent step becuase it requires a restart before we
##         can continue.
################################################################################

Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
Write-Host "Install Docker"
choco install docker-for-windows

Write-Host "Install-Package Docker-Compose"
choco install docker-compose

Write-Host "Install Helm"
choco install kubernetes-helm

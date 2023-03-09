
################################################################################
##  File:  Install-Oackages.ps1
##  Desc:  Install Chocolatey Packages.
################################################################################

Write-Host "VSEnterprise2019"
choco install visualstudio2019enterprise --package-parameters "--allWorkloads --includeRecommended --includeOptional --locale en-US" --execution-timeout 14400
param(
    [Parameter(Mandatory)]
    $account,
    [Parameter(Mandatory)]
    $PAT,
    [Parameter(Mandatory)]
    $PoolName,
    [Parameter(Mandatory)]
    $owaspStorageAccount,
    [Parameter(Mandatory)]
    $owaspPassword,
    $PartitionSize = 128

)
Write-Information "###### Remove old MMA certifcates ######"
Get-Service "HealthService" | Stop-Service

Move-Item "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State" -Destination "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State.old"
Move-Item "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation" -Destination "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation.old"
Get-Item -Path "HKLM:\SOFTWARE\Microsoft\HybridRunbookWorker" | Remove-Item -Recurse

Set-Location 'Cert:\LocalMachine\Microsoft Monitoring Agent'

Get-ChildItem | Remove-Item -Recurse

Write-Information "###### Expand out the drive ######"
$size = $PartionSize + "GB"
Resize-Partition -DiskNumber 0 -PartitionNumer 2 -Size ($size)

Write-Information "###### Get latest NVD ######"
# Add nvd dc
# Save the password so the drive will persist on reboot
Invoke-Expression -Command "cmdkey /add:$owaspStorageAccount.file.core.windows.net /user:AZURE\$owaspStorageAccount /pass:$owaspPassword"

# Mount the drive
#net use Z: \\$owaspStorageAccount.file.core.windows.net\owaspdependencycheck $owaspPassword /user:Azure\$owaspStorageAccount
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$owaspStorageAccount.file.core.windows.net\owaspdependencycheck" -Persist

New-Item C:\dependency-check -ItemType Directory

Copy-Item -Path Z:\dependency-check\* -Destination C:\dependency-check -Recurse


Write-Information "###### ADD dc to path ######"
# Save the password so the drive will persist on reboot
$dcpath = "C:\dependency-check\bin"

$path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
[System.Environment]::SetEnvironmentVariable("Path", $path + ";$dcpath", "Machine")

Write-Information "###### Check canary Capability ######"
if ($env:ComputerName -like "win19-c*") {
    [System.Environment]::SetEnvironmentVariable("CANARY", "Yes", "Machine")
}

Write-Information "###### Setup vsts agent ######"
$data = Invoke-RestMethod -Uri https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | Select Name

$agentVersion = $data.Name.replace('v', '')

$zip = "vsts-agent-win-x64-$agentVersion.zip"

New-Item C:\agt -ItemType Directory

Set-Location C:\agt

wget "https://vstsagentpackage.azureedge.net/agent/$agentVersion/$zip" -OutFile ./$zip

$agentName = "$env:ComputerName"
    
Expand-Archive -Path ./$zip -DestinationPath .

Add-LocalGroupMember -Group Administrators -Member "NT AUTHORITY\NetworkService"
.\config.cmd --unattended --url https://dev.azure.com/$account --auth PAT --token $PAT --pool "$PoolName" --agent "$agentName" --runAsService

Write-Information "###### INSTALL DRAINER ######"

choco install nssm -y

$installPath = "C:\drainer"
New-Item $installPath -ItemType Directory
Set-Location $installPath
$zip = "azurevmagentservice.zip"
wget "https://github.com/UKHO/AzDoAgentDrainer/releases/latest/download/azurevmagentservice.zip" -OutFile ./$zip
Expand-Archive -Path ./$zip -DestinationPath .

$scriptName = "runAzureVMService.bat"
New-Item -Path . -Name $scriptName -ItemType "file" -Value "dotnet AzureVmAgentsService.dll --drainer:uri=https://dev.azure.com/$account --drainer:pat=$PAT"
nssm install AzureVmAgentsService "$installPath\$scriptName"
nssm start AzureVmAgentsService

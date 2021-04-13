param(
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

Write-Information "###### Docker Service Config ######"
SC failure docker reset=0 actions=restart/60000/restart/60000/run/60000 command=""shutdown" "/T00""

Write-Information "###### Docker Service Restart ######"
$varService = "docker"
Get-Service -Name $varService | Restart-Service

$path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
[System.Environment]::SetEnvironmentVariable("Path", $path + ";$dcpath", "Machine")

Write-Information "###### Check canary Capability ######"
if ($env:ComputerName -like "win19-c*") {
    [System.Environment]::SetEnvironmentVariable("CANARY", "Yes", "Machine")
}

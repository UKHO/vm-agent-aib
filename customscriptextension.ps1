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
$owaspUser,
[Parameter(Mandatory)]
$owaspPassword,
$PartitionSize = 128
)

$size = $PartionSize + "GB"

Resize-Partition -DiskNumber 0 -PartitionNumer 2 -Size ($size)


# Setup NVD
$connectTestResult = Test-NetConnection -ComputerName "$owaspStorageAccount.file.core.windows.net" -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"$owaspStorageAccount.file.core.windows.net`" /user:`"$owaspUser`" /pass:`"$owaspPassword`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$owaspStorageAccount.file.core.windows.net\owaspdependencycheck"-Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}

$dcpath = "Z:\dependency-check\bin"

$path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
[System.Environment]::SetEnvironmentVariable("Path", $path + ";$dcpath", "Machine")

# Setup vsts agent
$data = Invoke-RestMethod -Uri https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | Select Name

$agentVersion = $data.Name.replace('v','')

$zip = "vsts-agent-win-x64-$agentVersion.zip"

New-Item C:\agt -ItemType Directory

Set-Location C:\agt

wget "https://vstsagentpackage.azureedge.net/agent/$agentVersion/$zip" -OutFile ./$zip

$agentName = "$env:ComputerName"
    
Expand-Archive -Path ./$zip -DestinationPath .
        
.\config.cmd --unattended --url https://dev.azure.com/$account --auth PAT --token $PAT --pool "$PoolName" --agent "$agentName" --runAsService #--windowsLogonAccount "$AdminAccount" --windowsLogonPassword "$AdminPassword"

Restart-Computer

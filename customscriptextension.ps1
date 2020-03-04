param(
[Parameter(Mandatory)]
$account,
[Parameter(Mandatory)]
$PAT,
[Parameter(Mandatory)]
$PoolName,
[Parameter(Mandatory)]
$ComputerName,
$AdminAccount,
$AdminPassword,
$count = 1,
$PartitionSize = 128
)

$size = $PartionSize + "GB"

Resize-Partition -DiskNumber 0 -PartitionNumer 2 -Size ($size)

# Setup vsts agent
$data = Invoke-RestMethod -Uri https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | Select Name

$agentVersion = $data.Name.replace('v','')

$zip = "vsts-agent-win-x64-$agentVersion.zip"

New-Item C:\agt -ItemType Directory

Set-Location C:\agt

wget "https://vstsagentpackage.azureedge.net/agent/$agentVersion/$zip" -OutFile ./$zip

$agentName = "$ComputerName"
    
Expand-Archive -Path ./$zip -DestinationPath .
        
.\config.cmd --unattended --url https://dev.azure.com/$account --auth PAT --token $PAT --pool "$PoolName" --agent "$agentName" --runAsService --windowsLogonAccount "$AdminAccount" --windowsLogonPassword "$AdminPassword"

Restart-Computer

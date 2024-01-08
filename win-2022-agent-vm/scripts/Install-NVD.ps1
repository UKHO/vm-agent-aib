param($NvdApiKey = "<NvdApiKey>")
Write-Host "Install NVD Checker"
Set-Location "C:\Temp"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
$latest = Invoke-RestMethod "https://api.github.com/repos/jeremylong/DependencyCheck/releases/latest"
$release = $latest | `
        Select-Object -ExpandProperty assets | Where-Object {$_.browser_download_url -Like "*-release.zip" -and $_.browser_download_url -NotLike "*-ant-*"} | `
        Select-Object -First 1

if ($null -ne $release) {
    $url = $release.browser_download_url

    Write-Host "Release $url"
    $leaf = Split-Path $url -Leaf

    Invoke-Command -ScriptBlock { 
        $ProgressPreference = 'SilentlyContinue' 
        Invoke-WebRequest $url -OutFile $leaf
    }

    $dir = Get-ChildItem $leaf | Select-Object -ExpandProperty BaseName

    #$zip = "$($dir).zip"
    # downloaded and saved from releases: https://github.com/jeremylong/DependencyCheck/releases
    #Copy-Item "\\mgmt.local\dfs\DML-SW-Engineering\OWASP Dependency Check\$zip" $WorkingDirectory -Force

    Write-Host "Expand zip"
    Expand-Archive .\$leaf -Force

    Write-Host "Move Temp to root"
    Move-Item .\$dir\dependency-check .\dependency-check -Force

    $content = Get-Content '.\dependency-check\bin\dependency-check.bat'

    $content = $content.Replace("org.owasp.dependencycheck.App %CMD_LINE_ARGS%", "org.owasp.dependencycheck.App %CMD_LINE_ARGS% -n")

    Write-Host "Set content with no update"
    Set-Content -Value $content -Path .\dependency-check\bin\dependency-check.bat

    .\dependency-check\bin\dependency-check.bat --update --nvdApiKey $NvdApiKey
    $currentPath = $Env:Path
    $owasppath = "C:\dependency-check\bin\"

    Write-Host "Adding $owasppath to environment path"
    $currentPath = $currentPath + ";" + $owasppath + ";"

    Write-Host $currentPath
    Write-Host "Set environment path"
    [System.Environment]::SetEnvironmentVariable("PATH", $currentPath, "Machine")
}

param($NvdApiKey)
"SET TEMP"
Set-Location "C:\Temp"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
$latest = Invoke-RestMethod "https://api.github.com/repos/jeremylong/DependencyCheck/releases/latest"
$release = $latest | `
        Select-Object -ExpandProperty assets | Where-Object {$_.browser_download_url -Like "*-release.zip" -and $_.browser_download_url -NotLike "*-ant-*"} | `
        Select-Object -First 1

if ($null -ne $release) {
    $url = $release.browser_download_url

    "Release $url"
    $leaf = Split-Path $url -Leaf

    Invoke-Command -ScriptBlock { 
        $ProgressPreference = 'SilentlyContinue' 
        Invoke-WebRequest $url -OutFile $leaf
    }

    $dir = Get-ChildItem $leaf | Select-Object -ExpandProperty BaseName

    #$zip = "$($dir).zip"
    # downloaded and saved from releases: https://github.com/jeremylong/DependencyCheck/releases
    #Copy-Item "\\mgmt.local\dfs\DML-SW-Engineering\OWASP Dependency Check\$zip" $WorkingDirectory -Force

    "Expand zip"
    Expand-Archive .\$leaf -Force

    "Move Temp to root"
    Move-Item .\$dir\dependency-check .\dependency-check -Force

    $content = Get-Content '.\dependency-check\bin\dependency-check.bat'

    $content = $content.Replace("org.owasp.dependencycheck.App %CMD_LINE_ARGS%", "org.owasp.dependencycheck.App %CMD_LINE_ARGS% -n")

    "Set content with no update"
    Set-Content -Value $content -Path .\dependency-check\bin\dependency-check.bat

    .\dependency-check\bin\dependency-check.bat --update --nvdApiKey $NvdApiKey
    $currentPath = $Env:Path
    $owasppath = "C:\dependency-check\bin\"

    $currentPath += $owasppath

    [Environment]::SetEnvironmentVariable("Path", $currentPath, "Machine") 
    

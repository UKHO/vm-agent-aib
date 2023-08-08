#v this didn't work
#https://stackoverflow.com/questions/40459280/docker-cannot-start-on-windows
#Write-Host "Starting docker daemon."
#& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon

#https://lippertmarkus.com/2021/09/04/containers-without-docker-desktop/
Enable-WindowsOptionalFeature -Online -FeatureName containers –All
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V –All

curl.exe -o docker.zip -LO https://download.docker.com/win/static/stable/x86_64/docker-20.10.13.zip 
Expand-Archive docker.zip -DestinationPath C:\
[Environment]::SetEnvironmentVariable("Path", "$($env:path);C:\docker", [System.EnvironmentVariableTarget]::Machine)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
dockerd --register-service
Start-Service docker
docker run hello-world
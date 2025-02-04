echo "Update package list"
apt update

echo "Install prerequisites"
apt install -y wget apt-transport-https

echo "Add Microsoft repository"
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb

echo "Update package list after adding repository"
apt update

echo "Install baseline packages"
apt install -y dotnet-sdk-8.0

echo "Install az copy for Ubuntu 22.04"
apt install -y azcopy

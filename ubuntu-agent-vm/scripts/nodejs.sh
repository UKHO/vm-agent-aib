apt update

apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    nano \
    unzip

curl -sL https://deb.nodesource.com/setup_10.x | bash -

apt update

apt install -y gcc g++ make

apt install -y nodejs

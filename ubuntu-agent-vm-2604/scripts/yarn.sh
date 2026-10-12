sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg \
  | sudo gpg --dearmor \
  -o /etc/apt/keyrings/yarn.gpg

echo \
  "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" \
  | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt update
sudo apt install -y yarn

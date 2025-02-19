echo "Checking to see if the repository exists already"
if [[ -z $(ls /etc/apt/sources.list.d/fw16-led-matrixd.list 2>/dev/null) ]]
then
	echo "Checking to see if the GPG key is installed"
	if [[ -z $(ls /etc/apt/trusted.gpg.d/nukingdragons.gpg 2>/dev/null) ]]
	then
		echo "Installing the repositories public GPG key to /etc/apt/trusted.gpg.d/nukingdragons.gpg"
		curl -s https://nukingdragons.github.io/key.gpg | sudo gpg --dearmor --output /etc/apt/trusted.gpg.d/nukingdragons.gpg
	else
		echo "GPG key already installed"
	fi

	echo "Adding the repository to /etc/apt/sources.list.d/fw16-led-matrixd.list"
	echo "deb [arch=$(uname -m | sed 's/x86_64/amd64/g') signed-by=/etc/apt/trusted.gpg.d/nukingdragons.gpg] https://nukingdragons.github.io/repos/fw16-led-matrixd/apt stable main" | sudo tee /etc/apt/sources.list.d/fw16-led-matrixd.list >/dev/null
else
	echo "Repository already exists"
fi

echo "Updating repositories and installing the daemon"
sudo apt update
sudo apt install fw16-led-matrixd

echo "Be sure to configure /etc/fw16-led-matrixd/config.toml, you can determine the ports by issuing the command at any time:"
echo "ledcli list"
echo ""
echo "Current ports on your system at this time"
ledcli list
echo ""
echo "If you are using systemd, make sure you start and enable the daemon after you update the config by issuing the following command:"
echo "sudo systemctl enable --now fw16-led-matrixd.service"

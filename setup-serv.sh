#!/bin/bash
set -e

echo "Provisioning script for kubernetes"

if docker --version &> /dev/null; then
	echo "docker sudah terinstall"
else
	echo "memulai installasi docker..."
	# Add Docker's official GPG key:
	 apt-get update
	 apt-get install ca-certificates curl -y
	 install -m 0755 -d /etc/apt/keyrings
	 curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	 chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
	echo \
 	 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
 	 $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  	 tee /etc/apt/sources.list.d/docker.list > /dev/null
	 apt-get update

	 apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
	 systemctl enable docker
	 systemctl start docker
	echo "Berhasil menginstall docker...."
fi



echo "installing kubectl"
if kubectl --version &> /dev/null; then
	echo "Kubectl sudah terinstall, siap digunakan"
else
	echo "memulai installasi kubectl...[stage 1]"
	sudo apt-get update
	# apt-transport-https may be a dummy package; if so, you can skip that package
	sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

	echo "memulai installasi kubectl...[stage 2]"
	curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

	echo "memulai installasi kubectl...[stage 3]"
	# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
	echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
	chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctl

	echo "memulai installasi kubectl...[stage 4]"
	apt-get update
	apt-get install -y kubectl
fi



echo "k3s installation...."
read -p "role node di kubernetes (cp | cp-sec | wk) : " role
cpnode1=082121990261
wk_ip=081312124020
k3stoken="a3ViZXJuYXRlc0BzdmlwYnNlcnYK"

if systemctl is-active --quiet k3s.service; then
	echo "telah terinstall kubectl"
else
	if [ "$role" = "cp" ]; then
	 	export K3S_TOKEN=$k3stoken
		curl -sfL https://get.k3s.io | sh -s - server --disable traefik --disable servicelb --disable local.storage --docker --cluster-init
	elif [ "$role" = "cp-sec" ]; then
		export K3S_TOKEN=$k3stoken
		curl -sfL https://get.k3s.io | sh -s - server --server https://$cpnode1:6443 --disable traefik --disable servicelb --disable local.storage --docker
	elif [ "$role" = "wk" ]; then
		export K3S_TOKEN=$k3stoken
		curl -sfL https://get.k3s.io | sh -s - agent --docker --server https://$wk_ip:6443
	else
		echo "error occured"
	fi
fi



#!/bin/bash
set -e

echo "========Provisioning script for kubernetes============="

if docker --version &> /dev/null; then
	echo "docker sudah terinstall"
else
	echo "[+]memulai installasi docker..."
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
	echo "[+]Berhasil menginstall docker...."
fi



echo "=======installing kubectl========="
if kubectl --version &> /dev/null; then
	echo "[+]Kubectl sudah terinstall, siap digunakan"
else
	echo "[+]memulai installasi kubectl...[stage 1]"
	sudo apt-get update
	# apt-transport-https may be a dummy package; if so, you can skip that package
	sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

	echo "[+]memulai installasi kubectl...[stage 2]"
	curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

	echo "[+]memulai installasi kubectl...[stage 3]"
	# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
	echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
	chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctl

	echo "[+]memulai installasi kubectl...[stage 4]"
	apt-get update
	apt-get install -y kubectl
fi



echo "========k3s installation========"
read -p "role node di kubernetes (cp | cp-sec | wk) : " role
#cpnode1=082121990261
k3stoken="a3ViZXJuYXRlc0BzdmlwYnNlcnYK"

if systemctl is-active --quiet k3s.service; then
	echo "telah terinstall kubectl"
else
	if [ "$role" = "cp" ]; then
	 	export K3S_TOKEN=$k3stoken
		curl -sfL https://get.k3s.io | sh -s - server --disable traefik --disable servicelb --disable local.storage --docker --cluster-init
	elif [ "$role" = "cp-sec" ]; then
		read -p "Masukan ip server control plane utama : " cpnode1
		export K3S_TOKEN=$k3stoken
		curl -sfL https://get.k3s.io | sh -s - server --server https://$cpnode1:6443 --disable traefik --disable servicelb --disable local.storage --docker
	elif [ "$role" = "wk" ]; then
		read -p "Masukan ip server control plane utama : " cpnode1
		export K3S_TOKEN=$k3stoken
		curl -sfL https://get.k3s.io | sh -s - agent --docker --server https://$cpnode1:6443
	else
		echo "error occured"
	fi
fi

systemctl restart k3s
echo "export config"
read -p "masukan home directory biasa anda : " dirhome
if [ ! -d "$dirhome/.kube" ]; then
	mkdir $dirhome/.kube
fi
cp /etc/rancher/k3s/k3s.yaml $dirhome/.kube/config.yaml
chown -R $USER:$USER $dirhome/.kube/
chmod -R 755 $dirhome/.kube/config.yaml
exporter="export KUBECONFIG=$dirhome/.kube/config.yaml"
if ! cat $dirhome/.bashrc | grep  "$exporter"; then
	echo "$exporter" >> $dirhome/.bashrc
else
	echo "sudah ada skip"
fi
source $dirhome/.bashrc
sleep 35
if ! kubectl get node &> /dev/null; then
	echo "terdapat error pada k3s anda"

fi

echo "=====helm installation====="
if kubectl get node &> /dev/null | grep -q control-plane; then
  	read -p "masukan"
	apt-get install curl gpg apt-transport-https --yes
	curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor |  tee /usr/share/keyrings/helm.gpg > /dev/null
	echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" |  tee /etc/apt/sources.list.d/helm-stable-debian.list
	apt-get update
	apt-get install helm
else
	echo "your helm already installed"
fi

echo "Provisioning end....."

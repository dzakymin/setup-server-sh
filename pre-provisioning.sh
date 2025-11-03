#!/bin/bash

set -e

echo "[+]installing jq lib..."
sudo apt install jq -y

echo "[+]Installing open-iscsi...."
sudo apt install open-iscsi -y

echo "[+]Enabling iscsi_tcp for kernel longhorn purposes...."
sudo modprobe iscsi_tcp

echo "[+]Enabling iscsi service...."
#sudo systemctl enable iscsi.service
#sudo systemctl start iscsi.service

echo "[+]Installing nfs-common...."
sudo apt install nfs-common -y

echo "[+]Installing cryptsetup...."
sudo apt install cryptsetup -y

echo "[+]Disabling multipath sockerd"
if sudo systemctl stop multipath multipathd.service; then
	echo "Your system doesn't have multipath, skipp"
else
	echo "shutdown your multipath"

fi

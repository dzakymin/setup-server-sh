#!/bin/bash

set -e

echo "[+] installing open-iscsi...."
apt install open-iscsi -y

echo "[+]enabling iscsi_tcp for kernel longhorn purposes...."
modprobe iscsi_tcp

echo "[+]enabling iscsi service...."
systemctl enable iscsi.service
systemctl start iscsi.service

echo "[+]installing nfs-common...."
apt install nfs-common -y


if ! curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.7.1/scripts/environment_check.sh | sudo bash &> /dev/null; then
	echo "[*]Ada package yang kurang unutk melakukan provissioning"
else
	echo "[+]Pre-provisioning berhasil"
fi



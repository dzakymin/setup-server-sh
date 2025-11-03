#!/bin/bash

set -e

echo "[+] installing open-iscsi...."
sudo apt install open-iscsi -y

echo "[+]enabling iscsi_tcp for kernel longhorn purposes...."
sudo modprobe iscsi_tcp

echo "[+]enabling iscsi service...."
sudo systemctl enable iscsi.service
sudo systemctl start iscsi.service

echo "[+]installing nfs-common...."
sudo apt install nfs-common -y




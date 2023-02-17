#!/bin/bash
#############################
# Script Definition
#############################
logpath=/var/log/deploymentscriptlog
sudo touch /var/log/deploymentscriptlog
sudo chgrp adm /var/log/deploymentscriptlog
sudo chmod g+w /var/log/deploymentscriptlog

echo "#############################" >> $logpath
echo "SCRIPT START" >> $logpath
echo "$(date)" >> $logpath
echo "#############################" >> $logpath

#############################
# Upgrading Linux Distribution
#############################
echo "#############################" >> $logpath
echo "Upgrading Linux Distribution" >> $logpath
echo "Start: $(date)" >> $logpath
echo "#############################" >> $logpath
sudo apt-get update >> $logpath
sudo apt-get -y upgrade >> $logpath
echo " " >> $logpath

#############################
#Install Azure CLI
#############################
echo "#############################" >> $logpath
echo "Installing Azure CLI" >> $logpath
echo "Start: $(date)" >> $logpath
echo "#############################" >> $logpath
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash >> $logpath
sudo az extension add --name azure-iot >> $logpath
echo " " >> $logpath

#############################
#Add  IoT Edge Repo
#############################
echo "#############################" >> $logpath
echo "Adding IoT Edge Repo" >> $logpath
echo "Start: $(date)" >> $logpath
echo "#############################" >> $logpath
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb >> $logpath
sudo dpkg -i packages-microsoft-prod.deb >> $logpath
rm packages-microsoft-prod.deb >> $logpath
echo " " >> $logpath

#############################
#Install Container Engine
#############################
echo "#############################" >> $logpath
echo "Installing Container Engine" >> $logpath
echo "Start: $(date)" >> $logpath
echo "#############################" >> $logpath
sudo apt-get update >> $logpath
sudo apt-get install -y moby-engine >> $logpath
echo " " >> $logpath

#############################
#Create Local Logging Config
#############################
echo "#############################" >> $logpath
echo "Creating Local Logging Config" >> $logpath
echo "Start: $(date)" >> $logpath
echo "#############################" >> $logpath
sudo tee /etc/docker/daemon.json >> $logpath <<EOF
{
  "log-driver": "local"
}
EOF
echo " " >> $logpath

#############################
#Restart Docker
#############################
echo "#############################" >> $logpath
echo "Restarting Docker" >> $logpath
echo "Start: $(date)" >> $logpath
echo "#############################" >> $logpath
sudo systemctl restart docker >> $logpath
echo " " >> $logpath

#############################
#Install IoT Edge Runtime
#############################
echo "#############################" >> $logpath
echo "Installing IoT Edge Runtime" >> $logpath
echo "Start: $(date)" >> $logpath
echo "#############################" >> $logpath
sudo apt-get install -y aziot-edge defender-iot-micro-agent-edge >> $logpath
echo " " >> $logpath

#############################
#Configure Device Identity
#############################
echo "#############################" >> $logpath
echo "Configuring Device Identity" >> $logpath
echo "Start: $(date)" >> $logpath
echo "#############################" >> $logpath
sudo az login --identity >> $logpath
iothubname=$(sudo az iot hub list --query "[0].name" -o tsv)
iotrg=$(sudo az iot hub list --query "[0].resourcegroup" -o tsv)
sudo az iot hub device-identity create --device-id $(hostname) --hub-name $iothubname --resource-group $iotrg --edge-enabled >> $logpath
sudo iotedge config mp --connection-string $(sudo az iot hub device-identity connection-string show --device-id $(hostname) --hub-name $iothubname --resource-group $iotrg -o tsv) >> $logpath
sudo iotedge config apply >> $logpath
echo " " >> $logpath

echo "#############################" >> $logpath
echo "SCRIPT COMPLETE" >> $logpath
echo "$(date)" >> $logpath
echo "#############################" >> $logpath

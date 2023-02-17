Using Azure CLI Login
  az login

Check and if necessary set to the proper subscription
  az account show
  az account set --name <SubscriptionName>

Look at and Verify the parameters-main.json. Resources will contain the "workloadName" and there are several SKUs that can be adjusted if desired as well as network and login settings for the IoT Edge VM.

Use Azure CLI to deploy the Bicep template (you can set the region with the -l parameter):
  az deployment sub create -n "demo-iot-hub" -l "EastUS" -f main.bicep -p parameters-main.json

After Creation Completes you should have:
  - Resource Group with:
    - IoT Hub
    - Container Registry
    - Storage Account
    - Virtual Network
        - Subnet for the VM
        - NSG to Control Access to the VM
    - VM with the IoT Edge Runtime installed and connected using Symmetric Keys. (https://learn.microsoft.com/en-us/azure/iot-edge/how-to-provision-single-device-linux-symmetric)
        - OS Disk
        - Virtual Network Interface Card
        - Public IP
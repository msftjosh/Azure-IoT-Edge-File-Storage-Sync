# 01a Infrastructure Bicep

1. Using Azure CLI Login
    ```
    az login
    ```
1. Check and if necessary set to the proper subscription
    ```
    az account show
    az account set --name <SubscriptionName>
    ```
1. Look at and Verify the parameters-main.json. Resources will contain the "workloadName" and there are several SKUs that can be adjusted if desired.

1. Use Azure CLI to deploy the Bicep template (you can set the region with the -l parameter):
    ```
    az deployment sub create -n "demo-iot-hub" -l "EastUS" -f main.bicep -p parameters-main.json
    ```
1. After Creation Completes you should have:
    - Resource Group with:
        - IoT Hub
        - Container Registry
        - Storage Account

1. You will need to add an IoT edge device before proceeding, please follow your IoT Edge Device Manufacture's guidance if available. Additional guidance can be found here: https://learn.microsoft.com/en-us/azure/iot-edge/about-iot-edge?view=iotedge-1.4

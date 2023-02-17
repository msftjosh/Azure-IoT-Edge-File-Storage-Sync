# 02 Edge Blob Storage
## Add and configure the Blob Storage Module
1. In the Azure portal open up the IoT Hub resource >> Devices >> Select the IoT Edge Device >> Set modules >> Add IoT Edge Module from Marketplace

1. Find the "Azure Blob Storage on IoT" Edge Module

1. Once back on the Set Modules page select the newly created AzureBlobStorageIoTEdge module

1. Leave the Settings tab as is
1. On the "Environment Variables" tab delete the two default Environment Variables (setting them in the Container Create Options)
1. Copy the JSON in the CONTAINER CREATE OPTIONS section below into the "Container Create Options" tab and make any adjustments necessary (set the LOCAL_STORAGE_ACCOUNT_NAME and LOCAL_STORAGE_ACCOUNT_KEY - you can create a 64 Byte key using: https://generate.plus/en/base64)

    CONTAINER CREATE OPTIONS
    ```
    {
        "Env": [
            "LOCAL_STORAGE_ACCOUNT_NAME=<LOCAL-STORAGE-ACCOUNT-NAME>",
            "LOCAL_STORAGE_ACCOUNT_KEY=<64-BYTE-BASE64-STRING>"
        ],
        "HostConfig": {
            "Binds": [
                "blob-volume:/blobroot"
            ],
            "PortBindings": {
                "11002/tcp": [
                    {
                        "HostPort": "11002"
                    }
                ]
            }
        }
    }
    ```

1. Copy the JSON in the MODULE TWIN SETTINGS section below into the "Module Twin Settings" tab
    - Make any adjustments necessary eg. set the cloudStorageConnectionString to the primary key from the cloud hosted storage account. 

    MODULE TWIN SETTINGS
    ```
    {
        "deviceAutoDeleteProperties": {
            "deleteOn": true,
            "deleteAfterMinutes": 1440,
            "retainWhileUploading": true
        },
        "deviceToCloudUploadProperties": {
            "uploadOn": true,
            "uploadOrder": "OldestFirst",
            "cloudStorageConnectionString": "<PrimaryConnectionStringOfCloudHostedStorageAccount>",
            "storageContainersForUpload": {
                "container1": {
                    "target": "container1"
                }
            },
            "deleteAfterUpload": true
        }
    }
    ```

1. (Optional) You can set a specified path on the edge host using a bind mount if using bind mount
  For the container Create Options in the "HostConfig" section set the "Binds" as follows (you can change the path if desired but be sure to adjust the chown and chmod commands below as well):
    ```
      "Binds": [
              "/srv/containerdata:/blobroot"
          ],
    SSH into the VM and run the following commands:
      sudo chown -R 11000:11000 /srv/containerdata
      sudo chmod -R 700 /srv/containerdata
    ```

## Access the Local Blob Storage, Create a container, and test out syncronization
1. Open Microsoft Azure Storage Explorer (You can download it here: https://azure.microsoft.com/en-us/products/storage/storage-explorer/)
1. If it is not yet set to target Azure Stack APIs:
    - Click on Edit and Select "Target Azure Stack APIs"
    - Storage Explorer will need to restart
1. Add a Storage Account:
    - Right Click on Storage Accounts in the left hand menu and select "Connect to Azure Storage..."
    - Select "Storage account or service"
    - Be sure the "Connection string (Key or SAS) is selected and click "Next"
    - In the connection string box paste in the following string updated to reflect the values of the local strage blob module you created:
        ```
        DefaultEndpointsProtocol=https;BlobEndpoint=http://<IP-ADDRESS>:11002/<ACCOUNT-NAME>;AccountName=<ACCOUNT-NAME>;AccountKey=<ACCOUNT-KEY>
        ```
1. Once Connected in the left menu expand the storage account
1. Right Click on "Blob Containers" and select "Create Blob Container"
1. Name the container to match with the storageContainersForUpload in the Device Twin from above (in this case it was: "container1")
1. You can now open the container and upload a test file. If all settings were successfully set the uploaded file may not appear in the Storage Explorer as it was set to upload to the cloud Storage Account's blob and then set to auto delete the from the local Blob Storage, so check if the file appears in the mapped container in the Cloud hosted Storage Account's Blob storage. 



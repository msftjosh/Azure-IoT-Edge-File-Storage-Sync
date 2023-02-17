# 03 File Generator
## Create and Upload Container Image
1. Using the generate_random_file.py code we are going to create a container image and store it in our Azure Container registry. For this Exercise the Dockerfile is already created

1. Using Azure CLI executing in the directory where the pythong script and Dockerfile are (eg. cd "03 File Generator"):
    ```
    az acr build --image file-generator:v1 --registry \<ACRName> --file Dockerfile .
    ```
## Configure Module for IoT Edge Device
1. In portal open up the IoT Hub resource >> Devices >> Select the IoT Edge Device >> Set modules >> + Add "IoT Edge Module"
1. Give the module a name like filegenerator
1. On the Settings tab set the Image URL to:
    ```
    <ACRName>.azurecr.io/file-generator:v1
    ```
1. On the Environment Variables tab add the following Variables:
    
    | NAME                                        | TYPE   | VALUE                                                                               |
    | ------------------------------------------- | ------ | ----------------------------------------------------------------------------------- |
    | LOCAL_BLOB_STORAGE_CONNECTION_STRING        | Text   | DefaultEndpointsProtocol=https;BlobEndpoint=http://\<StorageBlobModuleName>:11002/\<StorageAccountName>;AccountName=\<StorageAccountName>;AccountKey=\<AccountKey>                                                                  |
    | LOCAL_BLOB_CONTAINER_NAME                   | Text   | \<ContainerName>                                                                    |
    | (Optional) FILE_GENERATION_INTERVAL_SECONDS | Number | 2048  (in Bytes; if not set will default to 1024 Bytes)                             |
    | (Optional) FILE_OUTPUT_PATH                 | Text   | <path>  (if not set will default to: '/app/output/'  - Recommended to not set this) |
    
1. Click Apply
1. On the Set Modules Page Add the Container Registry Credentials for your Azure Container Registry where the image is stored
    - Name: \<ACRName\>
    - Address: \<ACRName\>.azurecr.io
    - User Name: \<ACRName\>
    - Password: \<Password\> The password is genereated on the ACR Resrouce and can be found on the "Access Keys" Page
1. Click Review + Create
1. Click Create
1. After the New Module is online you should see files in the Syncronized Cloud Hosted Storage Account Blob Container.
## Cleanup
1. Once Complete it is recommend to go back into the Set modules for the IoT edge Device and Delete the File Generator so it stops generating files.

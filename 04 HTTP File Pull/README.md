# 04 HTTP/S File Pull
## Create and Upload Container Image
1. Using the pull_http_file_put_blob.py code we are going to create a container image and store it in our Azure Container registry. For this Exercise the Dockerfile is already. created
1. Using Azure CLI executing in the directory where the pythong script and Dockerfile are (eg. cd "03 File Generator"):
    ```azurecli
    az acr build --image pull-http-file-put-blob:v1 --registry <ACRName> --file Dockerfile .
    ```

## Configure Module for IoT Edge Device
1. In portal open up the IoT Hub resource >> Devices >> Select the IoT Edge Device >> Set modules >> + Add "IoT Edge Module"
1. Give the module a name like pullhttpfileputblob
1. On the Settings tab set the Image URL to:
    ```
    <ACRName>.azurecr.io/pull-http-file-put-blob:v1
    ```
1. On the Environment Variables tab add the following Variables:
    
    | NAME                                        | TYPE       | DESCRIPTION                                                                          |
    | ------------------------------------------- | ---------- | ------------------------------------------------------------------------------------ |
    | FILE_URL                                    | Text       | URL string for source file e.g. http://my-server.tld/image.jpg or https://username:password@10.10.10.10/image.jpg |
    | LOCAL_BLOB_STORAGE_CONNECTION_STRING        | Text       | DefaultEndpointsProtocol=https;BlobEndpoint=http://\<StorageBlobModuleName>:11002/\<StorageAccountName>;AccountName=\<StorageAccountName>;AccountKey=\<AccountKey> |
    | LOCAL_BLOB_CONTAINER_NAME                   | Text       | \<ContainerName>                                                                     |
    | (Optional) FILENAME_PREFIX                  | Text       | Prefix added to each uploaded file e.g. locationA would result in locationA_(originalFilename)_(timestamp).jpg (defaults to none) |
    | (Optional) PRESERVE_ORIGINAL_FILE_NAME      | True/False | Defaults to True, if set to false the original file name will not be passed as part of the filename of the uploaded blob | 
    | (Optional) FILE_PULL_INTERVAL_SECONDS       | Number     | Delay between pulls in Seconds; if not set will default to 60 seconds                |
    | (Optional) PULL_FILE_CACHE_PATH             | Text       | \<path>  (if not set will default to: '/app/output/'  - Recommended to not set this unless necessary due to storage constraints) |
    | (Optional) FILENAME_DELIMETER               | Text       | Delimeter between the filename parts. Defaults to _ (underscore)                     |

1. Click Apply
1. On the Set Modules Page The Container Registry Credentials should already exist from the previous exercise for your Azure Container Registry where the image is stored. Ensure the information is correct.
    - Name: \<ACRName\>
    - Address: \<ACRName\>.azurecr.io
    - User Name: \<ACRName\>
    - Password: \<Password\> The password is genereated on the ACR Resource and can be found on the "Access Keys" Page
1. Click Review + Create
1. Click Create
1. After the New Module is online you should see files in the Syncronized Cloud Hosted Storage Account Blob Container.
## Cleanup\Tuning
1. Once Complete it is recommend to go back into the Set modules for the IoT edge Device and either Delete the Pull HTTP File Module or ensure it is set to a proper interval to not create too many files.

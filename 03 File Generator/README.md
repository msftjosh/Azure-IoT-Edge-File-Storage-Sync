Using the generate_random_file.py code we are going to create a container image and store it in our Azure Container registry. For this Exercise the Dockerfile is already created

Using Azure CLI executing in the directory where the pythong script and Dockerfile are (eg. cd "03 File Generator"):
  az acr build --image file-generator:v1 --registry <ACRName> --file Dockerfile .

In portal open up the IoT Hub resource >> Devices >> Select the IoT Edge Device >> Set modules >> + Add "IoT Edge Module"
Give the module a name like filegenerator
On the Settings tab set the Image URL to:
  <ACRName>.azurecr.io/file-generator:v1
On the Environment Variables tab add the following Variables:
  Name: LOCAL_BLOB_STORAGE_CONNECTION_STRING  Type: Text  Value: DefaultEndpointsProtocol=https;BlobEndpoint=http://<StorageBlobModuleName>:11002/<StorageAccountName>;AccountName=<StorageAccountName>;AccountKey=<AccountKey>
  Name: LOCAL_BLOB_CONTAINER_NAME  Type: Text  Value: <ContainerName>
  (Optional) Name: FILE_GENERATION_INTERVAL_SECONDS  Type: Number  Value: 10  (in seconds; if not set will default to 60 Seconds)
  (Optional) Name: FILE_GENERATION_INTERVAL_SECONDS  Type: Number  Value: 2048  (in Bytes; if not set will default to 1024 Bytes)
  (Optional) Name: FILE_OUTPUT_PATH  Type: Text  Value: <path>  (if not set will default to: '/app/output/'  - Recommended to not set this)
Click Apply
On the Set Modules Page Add the Container Registry Credentials for your Azure Container Registry where the image is stored
Name: <ACRName>  ADDRESS: <ACRName>.azurecr.io  User Name: <ACRName>  Password: <Password>  The password is genereated on the ACR Resrouce and can be found on the "Access Keys" Page
Click Review + Create
Click Create

After the New Module is online you should see files in the Syncronized Cloud Hosted Storage Account Blob Container.

Once Complete it is recommend to go back into the Set modules for the IoT edge Device and Delete the File Generator so it stops generating files.
import random
import string
import time
import os
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient

OUTPUT_PATH = os.getenv('FILE_OUTPUT_PATH','/app/output/')
GENERATION_INTERVAL_SECONDS = os.getenv('FILE_GENERATION_INTERVAL_SECONDS', 60)
FILE_SIZE_BYTES = os.getenv('FILE_SIZE_BYTES', 1024)
LOCAL_BLOB_STORAGE_CONNECTION_STRING = os.getenv('LOCAL_BLOB_STORAGE_CONNECTION_STRING')
BLOB_CONTAINER_NAME = os.getenv('LOCAL_BLOB_CONTAINER_NAME')

isExist = os.path.exists(OUTPUT_PATH)
if not isExist:
   os.makedirs(OUTPUT_PATH)

def generate_random_file():
    random_data = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(int(FILE_SIZE_BYTES)))
    timestamp = time.strftime('%Y-%m-%d_%H%M%S', time.localtime())
    with open(OUTPUT_PATH+'random-file_'+timestamp+'.txt', 'w') as f:
        f.write(random_data)
    print('Generated file ' + f.name + ' with size ' + str(FILE_SIZE_BYTES) + ' bytes')
    return(f.name)

def put_file_in_blob(container_name, local_file_name, connect_str):
  blob_service_client = BlobServiceClient.from_connection_string(connect_str)
  blob_client = blob_service_client.get_blob_client(container=container_name, blob=os.path.basename(local_file_name))
  with open(file=local_file_name, mode="rb") as data:
    blob_client.upload_blob(data)
  os.remove(local_file_name)

if __name__ == '__main__':
    while True:
        LOCAL_FILE_NAME=generate_random_file()
        put_file_in_blob(BLOB_CONTAINER_NAME,LOCAL_FILE_NAME,LOCAL_BLOB_STORAGE_CONNECTION_STRING)
        time.sleep(int(GENERATION_INTERVAL_SECONDS))
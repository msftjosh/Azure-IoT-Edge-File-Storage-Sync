import time
import os
import requests
from pathlib import Path
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient

cache_path = os.getenv('PULL_FILE_CACHE_PATH','./file-cache/')
interval = int(os.getenv('FILE_PULL_INTERVAL_SECONDS', 60))
filename_prefix = os.getenv('FILENAME_PREFIX', '')
filename_delimeter = os.getenv('FILENAME_DELIMETER','_')
preserve_filename = os.getenv('PRESERVE_ORIGINAL_FILE_NAME', True)
file_url = os.getenv('FILE_URL')
blob_conn_str = os.getenv('LOCAL_BLOB_STORAGE_CONNECTION_STRING')
blob_container_name = os.getenv('LOCAL_BLOB_CONTAINER_NAME')
orig_filename = os.path.splitext(os.path.basename(file_url))[0]
orig_file_ext = os.path.splitext(os.path.basename(file_url))[1]

isExist = os.path.exists(cache_path)
if not isExist:
   os.makedirs(cache_path)

if not filename_prefix:
  set_filename_prefix = ''
else:
  set_filename_prefix = filename_prefix + filename_delimeter

if preserve_filename:
  filename=set_filename_prefix + orig_filename + filename_delimeter
else:
  filename=set_filename_prefix

blob_service_client = BlobServiceClient.from_connection_string(blob_conn_str)
container_client = blob_service_client.get_container_client(blob_container_name)

if not container_client.exists():
  container_client.create_container()
  print('Blob Container does not exist. Creating...')

def get_http_file():
  response = requests.get(file_url, allow_redirects=True)
  timestamp = time.strftime('%Y-%m-%dT%H%M%S', time.localtime())
  f = Path(cache_path + filename + timestamp + orig_file_ext)
  f.write_bytes(response.content)
  print('Put ' + str(f) + ' in local storage blob')
  return(f)

def put_file_in_blob():
  blob_service_client = BlobServiceClient.from_connection_string(blob_conn_str)
  blob_client = blob_service_client.get_blob_client(container=blob_container_name, blob=os.path.basename(local_filename))
  with open(file=local_filename, mode="rb") as data:
    blob_client.upload_blob(data)
  os.remove(local_filename)

if __name__ == '__main__':
  start_time = time.time()
  while True:
    local_filename=get_http_file()
    put_file_in_blob()
    time.sleep(interval - ((time.time() - start_time) % interval))

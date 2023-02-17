@description('IoT Hub SKU')
@allowed([
  'B1'
  'B2'
  'B3'
  'F1'
  'S1'
  'S2'
  'S3'
])
param skuName string
param skuUnits int
param location string
param iotHubName string

resource iotHub 'Microsoft.Devices/IotHubs@2022-04-30-preview' = {
  name: iotHubName
  location: location
  sku: {
    capacity: skuUnits
    name: skuName
  }
  properties: {
  }
}

output iotHubName string = iotHub.name
output iotHubId string = iotHub.id

targetScope = 'subscription'

// Parameters
param workloadName string
param location string = deployment().location
param iotHubSkuName string
param iotHubSkuUnits int
param allowedIpPrefixes array
param registrySku string
param storageAccountSku string

var workloadNameClean = replace(toLower(workloadName),'-','')

module rg 'modules/resource-group/rg.bicep' = {
  name: 'rg-${workloadName}'
  params: {
    rgName: 'rg-${workloadName}'
    location: location
  }
}

module iotHub 'modules/iot-hub/iot-hub.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'iot-${workloadName}'
  params: {
    iotHubName: 'iot-${workloadName}'
    skuName: iotHubSkuName
    skuUnits: iotHubSkuUnits
    location: location
  }
}

module containerRegistry 'modules/acr/containerregistry.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'acr-${workloadName}'
  params: {
    location: location
    registryName: 'acr${workloadNameClean}'
    registrySku: registrySku
    adminUserEnabled: true
  }
}

module storeageAccount 'modules/storage-account/storageaccount.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'sa-${workloadName}'
  params: {
    location: location
    storageAccountName: 'sa${workloadNameClean}'
    storageAccountSkuName: storageAccountSku
  }
}

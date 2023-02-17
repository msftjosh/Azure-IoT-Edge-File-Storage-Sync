param location string = resourceGroup().location
param storageAccountName string
param storageAccountKind string = 'StorageV2'
param storageAccountSkuName string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: storageAccountKind
  sku: {
    name: storageAccountSkuName
  }
}

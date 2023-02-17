param location string = resourceGroup().location
param registryName string
param registrySku string = 'Standard'
param adminUserEnabled bool = false

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: registrySku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

targetScope = 'subscription'

// Parameters
param workloadName string
param location string = deployment().location
param iotHubSkuName string
param iotHubSkuUnits int
param vnetAddressPrefixes array
param subnets array
param allowedAdminIpPrefixes array
param vmSubnetName string
param vmSize string
param vmAdminUsername string
@secure()
param vmAdminPassword string
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

module vnet 'modules/vnet/vnet.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'vnet-${workloadName}'
  params: {
    location: location
    vnetAddressSpace: {
        addressPrefixes: vnetAddressPrefixes
    }
    vnetName: 'vnet-${workloadName}'
    subnets: subnets
  }
  dependsOn: [
    rg
  ]
}

module nsgVmSubnet 'modules/vnet/nsg.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'nsg-${workloadName}'
  params: {
    location: location
    nsgName: 'nsg-${workloadName}'
    securityRules: [
      {
        name: 'AllowSSHInBound'
        properties: {
          priority: 100
          sourceAddressPrefixes: allowedAdminIpPrefixes
          protocol: 'Tcp'
          destinationPortRange: '22'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHTTPSInBound'
        properties: {
          priority: 105
          sourceAddressPrefixes: allowedAdminIpPrefixes
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowLocalSAInBound'
        properties: {
          priority: 110
          sourceAddressPrefixes: allowedAdminIpPrefixes
          protocol: 'Tcp'
          destinationPortRange: '11002'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

module updateNSG 'modules/vnet/subnet.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'updateNSG'
  params: {
    subnetName: vmSubnetName
    vnetName: vnet.name
    properties: {
      addressPrefix: subnetVm.properties.addressPrefix
      networkSecurityGroup: {
        id: nsgVmSubnet.outputs.nsgID
      }
    }
  }
}

resource subnetVm 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  scope: resourceGroup(rg.name)
  name: '${vnet.name}/${vmSubnetName}'
}

module iotEdgeVm 'modules/VM/virtualmachine.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'vm-${workloadName}'
  params: {
    vmName: 'vm-${workloadName}'
    location: location
    subnetId: subnetVm.id
    vmSize: vmSize
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    iotHubName: iotHub.name
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

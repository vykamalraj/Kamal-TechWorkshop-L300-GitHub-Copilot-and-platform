@description('Name of the Azure Container Registry')
param name string

@description('Location for the container registry')
param location string = resourceGroup().location

@description('SKU for the container registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Tags for the resource')
param tags object = {}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    dataEndpointEnabled: false
    networkRuleBypassOptions: 'AzureServices'
  }
}

@description('Login server for the container registry')
output loginServer string = containerRegistry.properties.loginServer

@description('Resource ID of the container registry')
output id string = containerRegistry.id

@description('Name of the container registry')
output name string = containerRegistry.name

@description('Name of the AI Hub')
param name string

@description('Location for the AI Hub')
param location string = resourceGroup().location

@description('Resource ID of the Application Insights')
param appInsightsId string

@description('Resource ID of the Container Registry')
param containerRegistryId string

@description('Tags for the resource')
param tags object = {}

// Storage account for AI Hub
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: replace('${name}storage', '-', '')
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

// Key Vault for AI Hub
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: replace('${name}-kv', '-', '')
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

// AI Hub (Machine Learning Workspace)
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    description: 'AI Hub for ZavaStorefront - GPT-4 and Phi models'
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: appInsightsId
    containerRegistry: containerRegistryId
    publicNetworkAccess: 'Enabled'
  }
  kind: 'Hub'
}

@description('Resource ID of the AI Hub')
output id string = aiHub.id

@description('Name of the AI Hub')
output name string = aiHub.name

@description('Storage account ID')
output storageAccountId string = storageAccount.id

@description('Key Vault ID')
output keyVaultId string = keyVault.id

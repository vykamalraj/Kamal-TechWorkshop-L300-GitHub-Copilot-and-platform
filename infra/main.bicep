targetScope = 'resourceGroup'

@description('Environment name')
@minLength(1)
@maxLength(64)
param environmentName string

@description('Location for all resources')
param location string = 'westus3'

@description('Docker image name and tag')
param dockerImageAndTag string = 'zavastorefrontapp:latest'

@description('Tags for all resources')
param tags object = {
  environment: 'dev'
  application: 'ZavaStorefront'
}

// Generate unique resource names based on environment and location
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var prefix = 'zavastore'

// Resource names
var acrName = '${prefix}acr${resourceToken}'
var logAnalyticsName = '${prefix}-logs-${resourceToken}'
var appInsightsName = '${prefix}-ai-${resourceToken}'
var appServicePlanName = '${prefix}-plan-${resourceToken}'
var appServiceName = '${prefix}-app-${resourceToken}'
var aiHubName = '${prefix}-aihub-${resourceToken}'

// Log Analytics Workspace
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

// Application Insights
module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsights'
  params: {
    name: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.id
    tags: tags
  }
}

// Azure Container Registry
module acr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    name: acrName
    location: location
    sku: 'Basic'
    tags: tags
  }
}

// App Service Plan (Linux)
module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: appServicePlanName
    location: location
    sku: 'B1'
    tags: tags
  }
}

// App Service (Web App for Containers)
module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    name: appServiceName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    acrLoginServer: acr.outputs.loginServer
    dockerImageAndTag: dockerImageAndTag
    appInsightsConnectionString: appInsights.outputs.connectionString
    tags: tags
  }
}

// Role Assignment - Grant App Service AcrPull role on ACR
module roleAssignment 'modules/roleAssignment.bicep' = {
  name: 'roleAssignment'
  params: {
    principalId: appService.outputs.principalId
    acrId: acr.outputs.id
  }
}

// AI Hub (Microsoft Foundry)
module aiHub 'modules/aiHub.bicep' = {
  name: 'aiHub'
  params: {
    name: aiHubName
    location: location
    appInsightsId: appInsights.outputs.id
    containerRegistryId: acr.outputs.id
    tags: tags
  }
}

// Outputs
@description('Azure Container Registry login server')
output acrLoginServer string = acr.outputs.loginServer

@description('Azure Container Registry name')
output acrName string = acr.outputs.name

@description('App Service default hostname')
output appServiceUrl string = 'https://${appService.outputs.defaultHostname}'

@description('App Service name')
output appServiceName string = appService.outputs.name

@description('Application Insights connection string')
output appInsightsConnectionString string = appInsights.outputs.connectionString

@description('AI Hub name')
output aiHubName string = aiHub.outputs.name

@description('Name of the App Service')
param name string

@description('Location for the App Service')
param location string = resourceGroup().location

@description('Resource ID of the App Service Plan')
param appServicePlanId string

@description('Login server of the Azure Container Registry')
param acrLoginServer string

@description('Docker image name and tag')
param dockerImageAndTag string = 'nginx:latest'

@description('Application Insights connection string')
param appInsightsConnectionString string = ''

@description('Tags for the resource')
param tags object = {}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/${dockerImageAndTag}'
      acrUseManagedIdentityCreds: true
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
      ]
    }
  }
}

@description('Resource ID of the App Service')
output id string = appService.id

@description('Default hostname of the App Service')
output defaultHostname string = appService.properties.defaultHostName

@description('Principal ID of the system-assigned managed identity')
output principalId string = appService.identity.principalId

@description('Name of the App Service')
output name string = appService.name

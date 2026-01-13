@description('Name of the Application Insights instance')
param name string

@description('Location for the Application Insights')
param location string = resourceGroup().location

@description('Resource ID of the Log Analytics workspace')
param workspaceResourceId string

@description('Application type')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Tags for the resource')
param tags object = {}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: workspaceResourceId
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('Resource ID of the Application Insights')
output id string = appInsights.id

@description('Instrumentation key for Application Insights')
output instrumentationKey string = appInsights.properties.InstrumentationKey

@description('Connection string for Application Insights')
output connectionString string = appInsights.properties.ConnectionString

@description('Name of the Application Insights')
output name string = appInsights.name

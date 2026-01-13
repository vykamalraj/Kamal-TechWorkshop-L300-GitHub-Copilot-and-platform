@description('Principal ID that will be assigned the role')
param principalId string

@description('Name of the Azure Container Registry')
param acrName string

@description('Role definition ID for AcrPull')
param roleDefinitionId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull

// Reference existing ACR
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, principalId, roleDefinitionId)
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

@description('Role assignment ID')
output id string = roleAssignment.id

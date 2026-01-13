@description('Principal ID that will be assigned the role')
param principalId string

@description('Resource ID of the Azure Container Registry')
param acrId string

@description('Role definition ID for AcrPull')
param roleDefinitionId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acrId, principalId, roleDefinitionId)
  scope: resourceId('Microsoft.ContainerRegistry/registries', last(split(acrId, '/')))
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

@description('Role assignment ID')
output id string = roleAssignment.id

targetScope = 'subscription'

param servicePrincipalId string = 'b9c8d7e6-f5a4-3210-fedc-ba9876543210'

var customRoleName = 'github-actions-companyname-role'

resource customRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(subscription().id, customRoleName)
  properties: {
    roleName: customRoleName
    description: 'Custom role for GitHub Actions to deploy Breakfast Technologies infrastructure'
    type: 'CustomRole'
    assignableScopes: [
      subscription().id
    ]
    permissions: [
      {
        actions: [
          'Microsoft.Resources/subscriptions/resourceGroups/read'
          'Microsoft.Resources/subscriptions/resourceGroups/write'
          'Microsoft.Resources/deployments/*'
          'Microsoft.Web/serverfarms/write'
          'Microsoft.Web/sites/write'
          'Microsoft.Web/sites/config/write'
          'Microsoft.Web/sites/read'
          'Microsoft.Web/sites/publish/action'
          'Microsoft.Web/sites/config/read'
          'Microsoft.Web/sites/config/list/action'
          'Microsoft.Web/sites/publishxml/action'
          'Microsoft.KeyVault/vaults/write'
          'Microsoft.KeyVault/vaults/secrets/write'
          'Microsoft.Authorization/roleAssignments/write'
          'Microsoft.Authorization/roleAssignments/read'
          'Microsoft.KeyVault/vaults/deploy/action'
          'Microsoft.Web/certificates/write'
          'Microsoft.Web/sites/hostNameBindings/write'
          'Microsoft.KeyVault/vaults/secrets/read'
          'Microsoft.Web/sites/hostNameBindings/read'
          'Microsoft.Web/certificates/read'
          'Microsoft.OperationalInsights/workspaces/write'
          'Microsoft.Insights/diagnosticSettings/write'
        ]
        notActions: []
      }
    ]
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, servicePrincipalId, customRole.id)
  properties: {
    roleDefinitionId: customRole.id
    principalId: servicePrincipalId
    principalType: 'ServicePrincipal'
  }
}



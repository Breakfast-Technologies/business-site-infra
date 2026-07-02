param location string
param appServicePlanName string = 'plan-companyname'
param appServiceName string = 'app-companyname'



resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      appCommandLine: 'uvicorn main:app --host 0.0.0.0'
      appSettings: [
        {
          name: 'EMAIL_API_KEY'
          value: '@Microsoft.KeyVault(VaultName=kv-companyname;SecretName=EMAIL-API-KEY)'
        }
        {
          name: 'TURNSTILE_SECRET_KEY'
          value: '@Microsoft.KeyVault(VaultName=kv-companyname;SecretName=TURNSTILE-SECRET-KEY)'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ]
    }
  }
}


output principalId string = appService.identity.principalId

output appServiceName string = appService.name
output appServicePlanId string = appServicePlan.id

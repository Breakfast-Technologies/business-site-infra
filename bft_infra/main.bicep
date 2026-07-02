targetScope = 'subscription'

param location string  = 'australiaeast'
param resourceGroupName string = 'rg-companyname'

@secure()
param emailApiKey string

@secure()
param turnstileSecretKey string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module appService 'modules/appservice.bicep' = {
  name: 'appServiceDeployment'
  scope: rg
  params: {
    location: location
  }
}

module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVaultDeployment'
  scope: rg
  params: {
    location: location
    emailApiKey: emailApiKey
    turnstileSecretKey: turnstileSecretKey
    appServicePrincipalId: appService.outputs.principalId
  }
}

module certificate 'modules/certificates.bicep' = {
  name: 'certificateDeployment'
  scope: rg
  params: {
    location: location
    appServiceName: appService.outputs.appServiceName
    appServicePlanId: appService.outputs.appServicePlanId
  }
}

module sslBinding 'modules/ssl-binding.bicep' = {
  name: 'sslBindingDeployment'
  scope: rg
  params: {
    appServiceName: appService.outputs.appServiceName
    hostname: certificate.outputs.hostname
    thumbprint: certificate.outputs.thumbprint
  }
}



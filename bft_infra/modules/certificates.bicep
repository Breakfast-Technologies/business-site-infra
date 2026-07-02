param location string
param appServiceName string
param appServicePlanId string
param hostname string = 'www.companyname.com'

resource hostNameBinding 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  name: '${appServiceName}/${hostname}'
  properties: {
    siteName: appServiceName
    hostNameType: 'Verified'
  }
}

resource managedCertificate 'Microsoft.Web/certificates@2022-03-01' = {
  name: 'cert-${appServiceName}'
  location: location
  properties: {
    serverFarmId: appServicePlanId
    canonicalName: hostname
  }
  dependsOn: [hostNameBinding]
}

output thumbprint string = managedCertificate.properties.thumbprint
output hostname string = hostname

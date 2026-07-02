param appServiceName string
param hostname string
param thumbprint string

resource sslBinding 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  name: '${appServiceName}/${hostname}'
  properties: {
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

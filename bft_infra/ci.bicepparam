using './main.bicep'

param emailApiKey = getSecret('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'rg-companyname', 'kv-companyname', 'EMAIL-API-KEY')

param turnstileSecretKey = getSecret('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'rg-companyname', 'kv-companyname', 'TURNSTILE-SECRET-KEY')

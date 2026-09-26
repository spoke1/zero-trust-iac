// Protects the resource group it is deployed to against deletion.

@description('Name of the lock.')
param name string = 'do-not-delete'

resource lock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: name
  properties: {
    level: 'CanNotDelete'
    notes: 'Security logging foundation, managed by zero-trust-iac. Remove this lock deliberately before deleting resources.'
  }
}

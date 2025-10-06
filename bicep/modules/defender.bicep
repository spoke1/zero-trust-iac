targetScope = 'subscription'

@description('Enable Defender for common resource types')
param pricingTier string = 'Standard'

var plans = [
  'VirtualMachines'
  'AppServices'
  'SqlServers'
  'StorageAccounts'
  'KubernetesService'
  'ContainerRegistry'
  'KeyVaults'
  'Dns'
]

@batchSize(5)
resource defenderPricings 'Microsoft.Security/pricings@2023-01-01' = [for p in plans: {
  name: p
  properties: {
    pricingTier: pricingTier
  }
}]

using 'main.bicep'

// Development subscription: short retention, cost-conscious Defender plans,
// guardrails in audit mode so experiments are not blocked.

param environmentName = 'dev'
param logRetentionInDays = 30
param dailyQuotaGb = 5

param defenderPlans = [
  { name: 'Arm', subPlan: 'PerSubscription' }
  { name: 'KeyVaults', subPlan: 'PerKeyVault' }
]

param allowedLocations = [
  'westeurope'
  'germanywestcentral'
]
param policyEnforcementMode = 'DoNotEnforce'

param enableDeleteLock = false

using 'main.bicep'

// Production subscription: longer retention, broad Defender coverage,
// enforced guardrails and a delete lock on the security resource group.

param environmentName = 'prod'
param logRetentionInDays = 180

param defenderPlans = [
  { name: 'CloudPosture' }
  { name: 'VirtualMachines', subPlan: 'P2' }
  { name: 'StorageAccounts', subPlan: 'DefenderForStorageV2' }
  { name: 'KeyVaults', subPlan: 'PerKeyVault' }
  { name: 'Arm', subPlan: 'PerSubscription' }
  { name: 'Containers' }
  { name: 'AppServices' }
  { name: 'SqlServers' }
]

// Alert emails: set the team mailbox here or pass it at deployment time, e.g.
//   az deployment sub create ... --parameters securityContactEmails='secops@contoso.example'
param securityContactEmails = ''
param alertNotificationSeverity = 'Medium'

param allowedLocations = [
  'westeurope'
  'germanywestcentral'
]
param policyEnforcementMode = 'Default'

param enableDeleteLock = true

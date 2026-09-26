// Zero Trust security foundation for an Azure subscription:
// central security logging, Defender for Cloud, alert routing and guardrails.
targetScope = 'subscription'

metadata name = 'Zero Trust security foundation'
metadata description = 'Security logging, Microsoft Defender for Cloud and policy guardrails for one Azure subscription.'

import { defenderPlan } from 'types.bicep'

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

@description('Environment short name, used in resource names and tags.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string

@description('Short prefix for resource names, for example an organisation or platform code.')
@minLength(2)
@maxLength(8)
param prefix string = 'zt'

@description('Azure region for the resource group and the workspace. Defaults to the deployment location.')
param location string = deployment().location

@description('Additional tags. environment, workload and managedBy are always set.')
param tags object = {}

@description('Name of the security resource group.')
param resourceGroupName string = 'rg-${prefix}-security-${environmentName}'

@description('Name of the Log Analytics workspace.')
param workspaceName string = 'law-${prefix}-security-${environmentName}'

@description('Interactive retention of the workspace in days (30-730).')
@minValue(30)
@maxValue(730)
param logRetentionInDays int = 90

@description('Daily ingestion cap in GB. -1 disables the cap.')
param dailyQuotaGb int = -1

@description('Public network access to the workspace. Set to Disabled once Azure Monitor Private Link is in place.')
@allowed([
  'Enabled'
  'Disabled'
])
param workspacePublicNetworkAccess string = 'Enabled'

@description('Defender for Cloud plans to enable. Review the pricing before enabling plans in production.')
param defenderPlans defenderPlan[] = [
  { name: 'Arm', subPlan: 'PerSubscription' }
  { name: 'KeyVaults', subPlan: 'PerKeyVault' }
]

@description('Recipients of Defender for Cloud alert emails, separated by semicolons. Empty skips the configuration.')
param securityContactEmails string = ''

@description('Minimum alert severity that triggers an email.')
@allowed([
  'Low'
  'Medium'
  'High'
])
param alertNotificationSeverity string = 'High'

@description('Regions allowed for resources and resource groups. An empty list skips the policy assignments.')
param allowedLocations string[] = [
  location
]

@description('Default denies non-compliant deployments. DoNotEnforce only reports compliance.')
@allowed([
  'Default'
  'DoNotEnforce'
])
param policyEnforcementMode string = 'Default'

@description('Protects the security resource group with a CanNotDelete lock.')
param enableDeleteLock bool = true

// ---------------------------------------------------------------------------
// Resources
// ---------------------------------------------------------------------------

var allTags = union(tags, {
  environment: environmentName
  workload: 'security-foundation'
  managedBy: 'zero-trust-iac'
})

resource securityRg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: allTags
}

module workspace 'modules/logAnalytics.bicep' = {
  name: 'zt-workspace-${environmentName}'
  scope: securityRg
  params: {
    name: workspaceName
    location: location
    tags: allTags
    retentionInDays: logRetentionInDays
    dailyQuotaGb: dailyQuotaGb
    publicNetworkAccess: workspacePublicNetworkAccess
  }
}

module activityLog 'modules/activityLog.bicep' = {
  name: 'zt-activitylog-${environmentName}'
  params: {
    workspaceId: workspace.outputs.workspaceId
  }
}

module defender 'modules/defender.bicep' = {
  name: 'zt-defender-${environmentName}'
  params: {
    plans: defenderPlans
  }
}

module securityContacts 'modules/securityContacts.bicep' = if (!empty(securityContactEmails)) {
  name: 'zt-contacts-${environmentName}'
  params: {
    emails: securityContactEmails
    minimalSeverity: alertNotificationSeverity
  }
}

module guardrails 'modules/policy.bicep' = if (!empty(allowedLocations)) {
  name: 'zt-policy-${environmentName}'
  params: {
    allowedLocations: allowedLocations
    enforcementMode: policyEnforcementMode
    namePrefix: '${prefix}-${environmentName}'
  }
}

module deleteLock 'modules/lock.bicep' = if (enableDeleteLock) {
  name: 'zt-lock-${environmentName}'
  scope: securityRg
  dependsOn: [
    workspace
  ]
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

@description('Name of the security resource group.')
output resourceGroupName string = securityRg.name

@description('Resource ID of the security Log Analytics workspace.')
output workspaceId string = workspace.outputs.workspaceId

@description('Enabled Defender for Cloud plans.')
output defenderPlans string[] = defender.outputs.enabledPlans

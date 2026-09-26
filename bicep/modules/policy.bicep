// Guardrails as Azure Policy assignments on the subscription (built-in definitions only).
targetScope = 'subscription'

@description('Regions in which resources and resource groups may be created.')
@minLength(1)
param allowedLocations string[]

@description('Default denies non-compliant deployments. DoNotEnforce only reports compliance.')
@allowed([
  'Default'
  'DoNotEnforce'
])
param enforcementMode string = 'Default'

@description('Prefix for the assignment names (max. 64 characters in total).')
@maxLength(40)
param namePrefix string

var assignments = [
  {
    name: 'allowed-locations'
    displayName: 'Allowed locations for resources'
    // Built-in: Allowed locations
    definitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', 'e56962a6-4747-49cd-b67b-bf8b01975c4c')
  }
  {
    name: 'allowed-locations-rg'
    displayName: 'Allowed locations for resource groups'
    // Built-in: Allowed locations for resource groups
    definitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', 'e765b5de-1225-4ba3-bd56-1ac6695af988')
  }
]

resource assignment 'Microsoft.Authorization/policyAssignments@2025-03-01' = [
  for a in assignments: {
    name: '${namePrefix}-${a.name}'
    properties: {
      displayName: a.displayName
      description: 'Managed by zero-trust-iac. Keeps data and workloads in approved regions.'
      policyDefinitionId: a.definitionId
      enforcementMode: enforcementMode
      parameters: {
        listOfAllowedLocations: {
          value: allowedLocations
        }
      }
      nonComplianceMessages: [
        {
          message: 'Only these regions are allowed: ${join(allowedLocations, ', ')}.'
        }
      ]
    }
  }
]

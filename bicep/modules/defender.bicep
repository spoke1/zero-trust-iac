// Enables Microsoft Defender for Cloud plans on the subscription.
// Plans are deployed one at a time: parallel updates of pricings can conflict.
targetScope = 'subscription'

import { defenderPlan } from '../types.bicep'

@description('Defender for Cloud plans to enable (pricing tier Standard).')
param plans defenderPlan[]

@batchSize(1)
resource pricing 'Microsoft.Security/pricings@2024-01-01' = [
  for plan in plans: {
    name: plan.name
    properties: union({ pricingTier: 'Standard' }, plan.?subPlan != null ? { subPlan: plan.?subPlan } : {})
  }
]

@description('Names of the enabled plans.')
output enabledPlans string[] = [for (plan, i) in plans: pricing[i].name]

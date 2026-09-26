// Streams the subscription activity log (control plane) into the security workspace.
targetScope = 'subscription'

@description('Resource ID of the Log Analytics workspace.')
param workspaceId string

@description('Name of the diagnostic setting.')
param name string = 'activity-log-to-security-workspace'

var categories = [
  'Administrative'
  'Security'
  'Policy'
  'Alert'
  'Recommendation'
  'ServiceHealth'
  'ResourceHealth'
  'Autoscale'
]

// 2021-05-01-preview is the latest version of this resource type and the first to support category groups.
#disable-next-line use-recent-api-versions
resource activityLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: name
  properties: {
    workspaceId: workspaceId
    logs: [
      for category in categories: {
        category: category
        enabled: true
      }
    ]
  }
}

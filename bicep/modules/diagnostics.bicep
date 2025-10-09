param workspaceId string
param targetResourceId string
param name string = 'diagSettings'
param logsEnabled bool = true
param metricsEnabled bool = true

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: name
  scope: resource(targetResourceId)
  properties: {
    workspaceId: workspaceId
    logs: logsEnabled ? [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ] : []
    metrics: metricsEnabled ? [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ] : []
  }
}

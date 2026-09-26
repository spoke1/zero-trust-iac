// Central Log Analytics workspace for security logs.
// Local (shared key) authentication is disabled: ingestion and queries require Microsoft Entra ID.

@description('Name of the Log Analytics workspace.')
param name string

@description('Azure region of the workspace.')
param location string

@description('Tags applied to the workspace.')
param tags object = {}

@description('Interactive retention in days (30-730).')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90

@description('Daily ingestion cap in GB. -1 disables the cap.')
param dailyQuotaGb int = -1

@description('Public network access for ingestion and query. Use Disabled together with Azure Monitor Private Link.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

resource workspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: publicNetworkAccess
    publicNetworkAccessForQuery: publicNetworkAccess
    features: {
      disableLocalAuth: true
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Who queried the security logs? Send the workspace's own audit log (LAQueryLogs) to itself.
// 2021-05-01-preview is the latest version of this resource type and the first to support category groups.
#disable-next-line use-recent-api-versions
resource workspaceAudit 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'workspace-audit'
  scope: workspace
  properties: {
    workspaceId: workspace.id
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
  }
}

@description('Resource ID of the workspace.')
output workspaceId string = workspace.id

@description('Name of the workspace.')
output workspaceName string = workspace.name

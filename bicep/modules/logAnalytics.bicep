param name string
param location string
@minValue(7)
param retentionDays int = 30
param sku string = 'PerGB2018'

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  properties: {
    retentionInDays: retentionDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  sku: {
    name: sku
  }
}

output workspaceId string = law.id

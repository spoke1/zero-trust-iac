targetScope = 'subscription'

@description('Primary Azure region')
param location string = 'westeurope'

@description('Resource group for security + logging')
param rgName string = 'rg-sec-logging'

@description('Log Analytics workspace name')
param lawName string = 'law-sec'

module rg 'modules/rg.bicep' = {
  name: 'rg-sec-logging'
  params: {
    name: rgName
    location: location
  }
}

module law 'modules/logAnalytics.bicep' = {
  name: 'law-deploy'
  scope: resourceGroup(rgName)
  params: {
    name: lawName
    location: location
    retentionDays: 30
    sku: 'PerGB2018'
  }
}

module defender 'modules/defender.bicep' = {
  name: 'defender-enable'
}

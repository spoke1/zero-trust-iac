// Email notifications for Microsoft Defender for Cloud alerts.
targetScope = 'subscription'

@description('Recipients of alert notifications, separated by semicolons. Use a team mailbox or distribution list.')
@minLength(3)
param emails string

@description('Minimum alert severity that triggers an email.')
@allowed([
  'Low'
  'Medium'
  'High'
])
param minimalSeverity string = 'High'

resource contact 'Microsoft.Security/securityContacts@2023-12-01-preview' = {
  name: 'default'
  properties: {
    emails: emails
    isEnabled: true
    notificationsByRole: {
      state: 'On'
      roles: [
        'Owner'
      ]
    }
    notificationsSources: [
      {
        sourceType: 'Alert'
        minimalSeverity: minimalSeverity
      }
    ]
  }
}

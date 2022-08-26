/* Copyright (c) Microsoft Corporation. Licensed under the MIT license. */

// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*
SUMMARY: Module to deploy the Microsoft Defender for Cloud to the Hub Network 
DESCRIPTION: The following components will be options in this deployment
              Microsoft Defender
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

targetScope = 'subscription'

// REQUIRED PARAMETERS

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = deployment().location


// MICROSOFT DEFENDER PARAMETERS

@allowed([
  'On'
  'Off'
])
@description('Send all notifications in this scope.')
param parAlertNotifications string = 'Off'

@allowed([
  'On'
  'Off'
])
@description('Send all notifications in this scope to all admins.')
param parAlertsToAdminsNotifications string = 'Off'

@description('Email address of the contact, in the form of john@doe.com')
param parEmailSecurityContact string = ''

@description('Phone of the contact, in the form of 555-555-5555')
param parPhoneSecurityContact string = ''

// LOGGING PARAMETERS

@description('Log Analytics Workspace Resource Id Needed for Defender')
param parLogAnalyticsWorkspaceResourceId string

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

module defender '../../../azresources/Modules/Microsoft.Security/defenderForCloud/az.sec.defender.bicep' = {
  name: 'set-sub-defender-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    // Required parameters
    workspaceId: parLogAnalyticsWorkspaceResourceId
    // Non-required parameters
    securityContactProperties: {
      alertNotifications: parAlertNotifications
      alertsToAdmins: parAlertsToAdminsNotifications
      email: parEmailSecurityContact
      phone:  parPhoneSecurityContact 
    }
  }
}


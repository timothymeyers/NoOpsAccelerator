/*
SUMMARY: Module to add the customer usage attribution (PID) to Subscription deployments.
DESCRIPTION: This module will create a deployment at the management group level which will add the unique PID and location as the deployment name
VERSION: 1.0.0
*/

// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
targetScope = 'subscription'

// This is an empty deployment by design
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution

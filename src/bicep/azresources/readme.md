# NoOps Accelerator - AzResources Bicep Module Templates Folders

## Authored & Tested With

* [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.38.0
* bicep cli version v0.9.1
* [bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) v0.9.1 vscode extension

Module Tested on:

* Azure Commercial ✔️
* Azure Government ✔️
* Azure Government Secret ✔️
* Azure Government Top Secret ❔

> ✔️ = tested,  ❔= currently testing

## Overview

## Hub Spoke Folder

Hub Spoke Folder has core modules to build a Landing Zone. Each tier is built to be deployed seperatly or as one deployment.

## Modules Folder

This folder contains select bicep modules influenced from the [CARML](https://aka.ms/CARML) library that will be used to deploy AKS and the resources that it depends on, such as:

*  Application Gateway
*  Azure Firewalls
*  Azure Firewall Policies
*  Azure Kubernetes Services
*  Azure Security Center
*  Bastion Hosts
*  Container Registries
*  Key Vaults
*  Log Analytics Workspaces
*  Network Security
*  Policy Assignments
*  Policy Definitions
*  Private DNS Zones
*  Private Endpoints
*  Public IP address
*  Resource Groups
*  Role Assignments
*  Role Definitions
*  Route Tables
*  User Assigned Identities
*  Virtual Networks

These modules are called by the GitHub Actions located under the 'workflows' folder.

## Policy Folder

Modules folder houses the Common use cases for Azure Policy include implementing governance for resource consistency, regulatory compliance, security, cost, and management.

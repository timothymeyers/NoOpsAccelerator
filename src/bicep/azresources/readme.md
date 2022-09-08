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

Hub/ Spoke Core is the basis on creating a modular Hub/Spoke network design. This core is used in Platform creations. Each module in the core is designed to be deploy together or individually. 

![image](https://user-images.githubusercontent.com/5787207/189195399-4c7ad2bb-7e63-4343-b222-dea0485880a4.png)

## Modules Folder

In the context of the NoOps Accelerator, a module is described as a reusable, template-based building component(block) for Azure resource deployments using infrastructure as code. Each template should be able to accommodate as many resource-specific scenarios as is practical without limiting the user by presuming anything about them. 

This folder contains select bicep modules influenced from the [CARML](https://aka.ms/CARML) library 

![image](https://user-images.githubusercontent.com/5787207/189195506-19589856-a590-4efb-8809-1495d269a1cf.png)

## Policy Folder

Modules folder houses the Common use cases for Azure Policy include implementing governance for resource consistency, regulatory compliance, security, cost, and management.

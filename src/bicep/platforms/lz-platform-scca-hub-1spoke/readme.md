# NoOps Accelerator - Platforms - SCCA Compliant Hub - 1 Spoke

## Authored & Tested With

* [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.38.0
* bicep cli version v0.9.1
* [bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) v0.9.1 vscode extension

## Navigation

* [Overview](#overview)
* [Architecture](#architecture)
* [Pre-requisites](#pre-requisites)
* [Deployment](#deployment)
* [Parameters](#add-on-parameters)
* [Outputs](#Outputs)
* [Resource Types](#Resource-Types)

## Overview

This platform module deploys AKS Secure Hub/Spoke landing zone.

> NOTE: This is only the landing zone. The workloads will be deployed with the enclave or can be deployed after the landing zone is created.

Read on to understand what this landing zone does, and when you're ready, collect all of the pre-requisites, then deploy the landing zone.

## Architecture

## Pre-requisites

* One or more Azure subscriptions where you or an identity you manage has Owner RBAC permissions

* For deployments in the Azure Portal you need access to the portal in the cloud you want to deploy to, such as <https://portal.azure.com> or <https://portal.azure.us>.

* For deployments in BASH or a Windows shell, then a terminal instance with the AZ CLI installed is required. For example, Azure Cloud Shell, the MLZ development container, or a command shell on your local machine with the AZ CLI installed.

* For PowerShell deployments you need a PowerShell terminal with the Azure Az PowerShell module installed.

>NOTE: The AZ CLI will automatically install the Bicep tools when a command is run that needs them, or you can manually install them following the instructions here.
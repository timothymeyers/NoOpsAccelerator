# Overlays: NoOps Accelerator - Policy - NIST SP 800-53 R5 Policy

> **IMPORTANT: This is currenly work in progress.**

## Overview

Azure Policy is used to implement guardrails in your environment. Azure Policy supports organizational standards enforcement and at-scale compliance evaluation. With the ability to drill down to the per-resource and per-policy granularity, it offers an aggregated view to assess the overall condition of the environment through its compliance dashboard. Bulk remediation for existing resources and automated remediation for new resources both assist in bringing your resources into compliance.

Implementing governance for resource consistency, legal compliance, security, cost, and management are common use cases for Azure Policy. To assist you in getting started, your Azure environment already has built-in policy definitions for these typical use cases.

A collection of built-in Azure Policy Sets based on Regulatory Compliance are configured with Azure NoOps Accelerator. To boost compliance for logging, networking, and tagging requirements, custom policy sets have been developed. Through automation, these can be further expanded or eliminated as needed by the department.

## Built-In Policy Sets Assignments

## Authoring Guide

See [Azure Policy Authoring Guide](authoring-guide.md) for step-by-step instructions.

[nist80053r5Policyset]: https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5
[asbPolicySet]: https://docs.microsoft.com/security/benchmark/azure/overview
[fedrampmPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/fedramp-moderate
[fedramphPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/fedramp-high
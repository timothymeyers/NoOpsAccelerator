# NoOps Accelerator Naming standard

:page_with_curl: **Note:** The baseline deployment will ask for a "Prefix" which will be included in all the deployed resources.
The naming of resources is hard coded in the templates but can also be modified as required prior to deployment.

### Resource naming for the baseline deployment

**Compute naming**
Resource Name | Resource Type
---------|----------|
 rg-avd-{AzureRegion}-{Prefix}-pool-compute | Resource Group
 avail-avd-{AzureRegion}-{Prefix}-{nnn} | Availability set
 osdisk-{AzureRegion}-avd-{Prefix}-{nnn} | Disk
 nic-{nn}-{VM name} | Network Interface
 vm-avd-{Prefix}-{nn} | Virtual Machine

**Network naming**
Resource Name | Resource Type
---------|----------|
rg-avd-{Azure Region}-{Prefix}-network | Resource Group
nsg-avd-{Azure Region}-{Prefix}-{nnn} | Network Security Group
route-avd-{Azure Region}-{Prefix}-{nnn} | Route Table
vnet-avd-{Azure Region}-{Prefix}-{nnn} | Virtual Network
snet-avd-{Azure Region}-{Prefix}-{nnn} | Virtual Network
# Azure Regions Lookup overlay module

The AzureRM terraform provider is made easier to use with the aid of this Terraform module.

The Azure standard format, a short format for resource name, the CLI format, and a slug format are all supported for an Azure region, as are the short format for resource naming and the slug format.

It also provides the [paired region](https://docs.microsoft.com/en-us/azure/availability-zones/cross-region-replication-azure) associated to the current one.

Please refer to the [main.tf](main.tf) file for available regions.
Complete regions mapping is also available in [AZREGIONS.md](AZREGIONS.md) documentation.

## Usage

```hcl
module "mod_azure_region" {
  source  = "./terraform/core/overlays/regions"
  azure_region = "east-us"
}
```

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure\_region | Azure Region standard name, CLI name or slug format | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| location | Azure region in standard format |
| location\_cli | Azure region in Azure CLI name format |
| location\_short | Azure region in short format for resource naming purpose |
| location\_slug | Azure region in slug format |
| paired\_location | Azure paired region with the current one. All formats available as attributes.<pre>object({<br>  location (string): Azure paired region in standard format<br>  location_short (string): Azure paired region in short format for resource naming purpose<br>  location_cli (string): Azure paired region in CLI name format<br>  location_slug (string): Azure paired region in slug format<br>})</pre> |
<!-- END_TF_DOCS -->

## Related documentation

Azure regions: [azure.microsoft.com/en-us/global-infrastructure/regions/](https://azure.microsoft.com/en-us/global-infrastructure/regions/)
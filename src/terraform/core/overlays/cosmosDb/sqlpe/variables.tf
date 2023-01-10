# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# -
# - Azure CosmosDB Account
# -
variable "database_name" { 
    type        = string
    description = "Specifies the name of the CosmosDB Account."  
}

variable "offer_type" { 
    type        = string
    description = "Specifies the Offer Type to use for this CosmosDB Account - currently this can only be set to Standard."  
}


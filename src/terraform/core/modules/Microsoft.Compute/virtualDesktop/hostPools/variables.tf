variable "name" {
  description = "(Required) Specifies the name of the Virtual Desktop Workspace. Changing this forces a new resource to be created.  "
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}

variable "friendly_name" {
  description = "(Required) The friendly name of the Virtual Desktop Workspace."
  type        = string
}

variable "description" {
  description = "(Optional) The description of the Virtual Desktop Workspace. Defaults to `Virtual Desktop Workspace`."
  type        = string
  default = "Virtual Desktop Workspace"
}

variable "validate_environment" {
  description = "(Optional) Should the environment be validated. Defaults to `false`."
  type        = bool
  default = false
}

variable "type" {
  description = "(Optional) The type of Virtual Desktop Workspace. Possible values are `Personal` and `Pooled`. Defaults to `Pooled`."
  type        = string
  default = "Pooled"
}

variable "maximum_sessions_allowed" {
  description = "(Optional) The maximum number of sessions allowed for the Virtual Desktop Workspace. Defaults to `0`."
  type        = number
  default = 0
}

variable "load_balancer_type" {
  description = "(Optional) The type of load balancer that this host pool uses. Possible values are `BreadthFirst` and `DepthFirst`. Defaults to `BreadthFirst`."
  type        = string
  default = "BreadthFirst"
}

variable "personal_desktop_assignment_type" {
  description = "(Optional) The type of personal desktop assignment for the Virtual Desktop Workspace. Possible values are `Automatic` and `Direct`. Defaults to `Automatic`."
  type        = string
  default = "Automatic"
}

variable "preferred_app_group_type" {
  description = "(Optional) The type of preferred application group type for the Virtual Desktop Workspace. Possible values are `Desktop` and `RailApplications`. Defaults to `Desktop`."
  type        = string
  default = "Desktop"
}

variable "custom_rdp_properties" {
  description = "(Optional) A `custom_rdp_property` block as defined below."
  type        = list(object({
    name  = string
    value = string
  }))
}

variable "start_vm_on_connect" {
  description = "(Optional) Should the VM be started on connect. Defaults to `false`."
  type        = bool
  default = false
}

variable "registration_info" {
  description = "(Optional) A `registration_info` block as defined below."
  type        = object({
    expiration_date = string
    token_validity  = string
  })
  default = {
    expiration_date = ""
    token_validity = ""
  }
}

variable "tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}




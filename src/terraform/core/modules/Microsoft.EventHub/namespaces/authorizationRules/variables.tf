
variable "authorization_rule_name" {
  type        = string
  description = "The name of the EventHub Namespace Authorization Rule."
}

variable "eventhub_namespace_name" {
  type        = string
  description = "The name of the EventHub Namespace."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group where the EventHub Namespace exists."
}

variable "listen" {
  type        = bool
  description = "Is the EventHub Namespace Authorization Rule allowed to listen to the EventHub Namespace."
  default     = false
}

variable "send" {
  type        = bool
  description = "Is the EventHub Namespace Authorization Rule allowed to send to the EventHub Namespace."
  default     = false
}

variable "manage" {
  type        = bool
  description = "Is the EventHub Namespace Authorization Rule allowed to manage the EventHub Namespace."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

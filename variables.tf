# Generic naming variables
variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Optional suffix for the generated name"
  type        = string
  default     = ""
}

variable "use_caf_naming" {
  description = "Use the Azure CAF naming provider to generate default resource name. `custom_name` override this if set. Legacy default name is used if this is set to `false`."
  type        = bool
  default     = true
}

# Storage Firewall

variable "network_rules_enabled" {
  description = "Boolean to enable Network Rules on the Service Bus Namespace, requires `trusted_services_allowed`, `allowed_cidrs`, `subnet_ids` or `default_firewall_action` correctly set if enabled."
  type        = bool
  default     = false
}

variable "trusted_services_allowed" {
  description = "If True, then Azure Services that are known and trusted for this resource type are allowed to bypass firewall configuration."
  type        = bool
  default     = true
}

variable "allowed_cidrs" {
  description = "List of CIDR to allow access to that Service Bus Namespace."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Subnets to allow access to that Service Bus Namespace."
  type        = list(string)
  default     = []
}

variable "default_firewall_action" {
  description = "Which default firewalling policy to apply. Valid values are `Allow` or `Deny`."
  type        = string
  default     = "Deny"
}

variable "default_tags_enabled" {
  description = "Option to enable or disable default tags"
  type        = bool
  default     = true
}

variable "extra_tags" {
  description = "Extra tags to add"
  type        = map(string)
  default     = {}
}


variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
} 

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure location for Servicebus."
  type        = string
}


# Identity
variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Service Bus. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Service Bus."
  type        = list(string)
  default     = null
}

variable "namespace_parameters" {
  type = object({
    custom_name         = optional(string)
    sku                 = optional(string, "Standard")
    capacity            = optional(number, 0)
    local_auth_enabled  = optional(bool, true)
    zone_redundant      = optional(bool, false)
    minimum_tls_version = optional(string, "1.2")

    public_network_access_enabled = optional(bool, true)
  })
  default = {}
}

variable "namespace_authorizations" {
  description = "Object to specify which Namespace Authorization Rules need to be created."
  type = object({
    listen = optional(bool, true)
    send   = optional(bool, true)
    manage = optional(bool, true)
  })
  default = {}
}

variable "servicebus_queues" {
  type = list(object({
    name        = string
    custom_name = optional(string)

    status = optional(string, "Active")

    auto_delete_on_idle                     = optional(string)
    default_message_ttl                     = optional(string)
    duplicate_detection_history_time_window = optional(string)
    lock_duration                           = optional(string)
    max_message_size_in_kilobytes           = optional(number)
    max_size_in_megabytes                   = optional(number)
    max_delivery_count                      = optional(number, 10)

    enable_batched_operations            = optional(bool, true)
    enable_partitioning                  = optional(bool)
    enable_express                       = optional(bool)
    dead_lettering_on_message_expiration = optional(bool)
    requires_duplicate_detection         = optional(bool)
    requires_session                     = optional(bool)

    forward_to                        = optional(string)
    forward_dead_lettered_messages_to = optional(string)

    authorizations_custom_name = optional(string)
    authorizations = optional(object({
      listen = optional(bool, true)
      send   = optional(bool, true)
      manage = optional(bool, true)
    }), {})
  }))
  default = []
}

variable "servicebus_topics" {
  type = list(object({
    name        = string
    custom_name = optional(string) 

    status = optional(string, "Active")

    auto_delete_on_idle                     = optional(string)
    default_message_ttl                     = optional(string)
    duplicate_detection_history_time_window = optional(string)
    max_message_size_in_kilobytes           = optional(number)
    max_size_in_megabytes                   = optional(number)

    enable_batched_operations    = optional(bool)
    enable_partitioning          = optional(bool)
    enable_express               = optional(bool)
    requires_duplicate_detection = optional(bool)
    support_ordering             = optional(bool)

    authorizations_custom_name = optional(string)
    authorizations = optional(object({
      listen = optional(bool, true)
      send   = optional(bool, true)
      manage = optional(bool, true)
    }), {})
  }))
  default = []
}

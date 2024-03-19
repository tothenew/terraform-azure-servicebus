# Azure Service Bus feature

[![Lint Status](https://github.com/tothenew/terraform-aws-template/workflows/Lint/badge.svg)](https://github.com/tothenew/terraform-aws-template/actions)
[![LICENSE](https://img.shields.io/github/license/tothenew/terraform-aws-template)](https://github.com/tothenew/terraform-aws-template/blob/master/LICENSE)

This is a template to use for baseline. The default actions will provide updates for section bitween Requirements and Outputs.

The following content needed to be created and managed:
 - Introduction
     - Explaination of module 
     - Intended users
 - Resource created and managed by this module
 - Example Usages

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| azurecaf | ~> 1.2, >= 1.2.22 |
| azurerm | ~> 3.39 |

## Modules

This Terraform module creates an [Azure Service Bus](https://docs.microsoft.com/en-us/azure/service-bus/). 

```hcl
<!-- data "azurerm_subnet" "example" {
  name                 = "backend"
  virtual_network_name = "production"
  resource_group_name  = module.rg.resource_group_name
} -->

module "servicebus" {
  source  = "claranet/service-bus/azurerm"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  namespace_parameters = {
    sku = "Premium"
  }

  namespace_authorizations = {
    listen = true
    send   = false
  }

  # Network rules
  network_rules_enabled    = false
  trusted_services_allowed = true
  <!-- allowed_cidrs = [
    "1.2.3.4/32",
  ]
  subnet_ids = [
    data.azurerm_subnet.example.id,
  ] -->

  servicebus_queues = [{
    name                = "myqueue"
    default_message_ttl = "P1D" # 1 day

    dead_lettering_on_message_expiration = true

    authorizations = {
      listen = true
      send   = false
    }
  }]

  servicebus_topics = [{
    name                = "mytopic"
    default_message_ttl = 5 # 5min

    authorizations = {
      listen = true
      send   = true
      manage = false
    }
  }]

  extra_tags = {
    foo = "bar"
  }
}
```

## Resources

| Name | Type |
|------|------|
| [azurerm_servicebus_namespace.servicebus_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_namespace_authorization_rule.listen](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) | resource |
| [azurerm_servicebus_namespace_authorization_rule.manage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) | resource |
| [azurerm_servicebus_namespace_authorization_rule.send](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) | resource |
| [azurerm_servicebus_namespace_network_rule_set.network_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_network_rule_set) | resource |
| [azurerm_servicebus_queue.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_servicebus_queue_authorization_rule.listen](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) | resource |
| [azurerm_servicebus_queue_authorization_rule.manage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) | resource |
| [azurerm_servicebus_queue_authorization_rule.send](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) | resource |
| [azurerm_servicebus_topic.topic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) | resource |
| [azurerm_servicebus_topic_authorization_rule.listen](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) | resource |
| [azurerm_servicebus_topic_authorization_rule.manage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) | resource |
| [azurerm_servicebus_topic_authorization_rule.send](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_cidrs | List of CIDR to allow access to that Service Bus Namespace. | `list(string)` | `[]` | no |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| default\_firewall\_action | Which default firewalling policy to apply. Valid values are `Allow` or `Deny`. | `string` | `"Deny"` | no |
| default\_tags\_enabled | Option to enable or disable default tags | `bool` | `true` | no |
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | Extra tags to add | `map(string)` | `{}` | no |
| identity\_ids | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Service Bus. | `list(string)` | `null` | no |
| identity\_type | Specifies the type of Managed Service Identity that should be configured on this Service Bus. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both). | `string` | `"SystemAssigned"` | no |
| location | Azure location for Servicebus. | `string` | n/a | yes |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name | `string` | `""` | no |
| namespace\_authorizations | Object to specify which Namespace Authorization Rules need to be created. | <pre>object({<br>    listen = optional(bool, true)<br>    send   = optional(bool, true)<br>    manage = optional(bool, true)<br>  })</pre> | `{}` | no |
| namespace\_parameters | Object to handle Service Bus Namespace options.<pre>custom_name         = To override default resource name, generated if not set.<br>sku                 = Defines which tier to use. Options are `Basic`, `Standard` or `Premium`.<br>capacity            = Specifies the capacity. When SKU is `Premium`, capacity can be 1, 2, 4, 8 or 16.<br>local_auth_enabled  = Whether or not SAS authentication is enabled for the Service Bus Namespace.<br>zone_redundant      = Whether or not this resource is zone redundant. SKU needs to be `Premium`.<br>minimum_tls_version = The minimum supported TLS version for this Service Bus Namespace.<br><br>public_network_access_enabled = Is public network access enabled for the Service Bus Namespace?</pre> | <pre>object({<br>    custom_name         = optional(string)<br>    sku                 = optional(string, "Standard")<br>    capacity            = optional(number, 0)<br>    local_auth_enabled  = optional(bool, true)<br>    zone_redundant      = optional(bool, false)<br>    minimum_tls_version = optional(string, "1.2")<br><br>    public_network_access_enabled = optional(bool, true)<br>  })</pre> | `{}` | no |
| network\_rules\_enabled | Boolean to enable Network Rules on the Service Bus Namespace, requires `trusted_services_allowed`, `allowed_cidrs`, `subnet_ids` or `default_firewall_action` correctly set if enabled. | `bool` | `false` | no |
| resource\_group\_name | Name of the resource group | `string` | n/a | yes |
| servicebus\_queues | List of objects to create Queues with their options.<pre>name        = Short Queue name.<br>custom_name = Custom name for Azure resource.<br><br>status = The status of the Queue. Possible values are `Active`, `Creating`, `Deleting`, `Disabled`, `ReceiveDisabled`, `Renaming`, `SendDisabled`, `Unknown`. Note that `Restoring` is not accepted.<br><br>auto_delete_on_idle                     = Duration of the idle interval after which the Queue is automatically deleted.<br>default_message_ttl                     = Duration of the TTL of messages sent to this Queue.<br>duplicate_detection_history_time_window = Duration during which duplicates can be detected.<br>lock_duration                           = Duration of a peek-lock that is, the amount of time that the message is locked for other receivers. Maximum value is 5 minutes.<br>max_message_size_in_kilobytes           = Integer value which controls the maximum size of a message allowed on the Queue for Premium SKU.<br>max_size_in_megabytes                   = Integer value which controls the size of memory allocated for the Queue.<br>max_delivery_count                      = Integer value which controls when a message is automatically dead lettered.<br><br>enable_batched_operations            = Boolean flag which controls whether server-side batched operations are enabled.<br>enable_partitioning                  = Boolean flag which controls whether to enable the Queue to be partitioned across multiple message brokers. Partitioning is available at entity creation for all Queues and Topics in Basic or Standard SKUs.<br>enable_express                       = Boolean flag which controls whether Express Entities are enabled. An express Queue holds a message in memory temporarily before writing it to persistent storage.<br>dead_lettering_on_message_expiration = Boolean flag which controls whether the Queue has dead letter support when a message expires.<br>requires_duplicate_detection         = Boolean flag which controls whether the Queue requires duplicate detection.<br>requires_session                     = Boolean flag which controls whether the Queue requires sessions. This will allow ordered handling of unbounded sequences of related messages. With sessions enabled a Queue can guarantee first-in-first-out delivery of messages.<br><br>forward_to                        = The name of a Queue or Topic to automatically forward messages to.<br>forward_dead_lettered_messages_to = The name of a Queue or Topic to automatically forward dead lettered messages to.<br><br>authorizations_custom_name = To override default Queue Authorization Rules names, generated if not set (first with the custom name of the Queue if set, otherwise with Azure CAF).<br>authorizations             = Object with `listen`, `send` and `manage` attributes to create Queues Authorizations Rules.</pre> | <pre>list(object({<br>    name        = string<br>    custom_name = optional(string)<br><br>    status = optional(string, "Active")<br><br>    auto_delete_on_idle                     = optional(string)<br>    default_message_ttl                     = optional(string)<br>    duplicate_detection_history_time_window = optional(string)<br>    lock_duration                           = optional(string)<br>    max_message_size_in_kilobytes           = optional(number)<br>    max_size_in_megabytes                   = optional(number)<br>    max_delivery_count                      = optional(number, 10)<br><br>    enable_batched_operations            = optional(bool, true)<br>    enable_partitioning                  = optional(bool)<br>    enable_express                       = optional(bool)<br>    dead_lettering_on_message_expiration = optional(bool)<br>    requires_duplicate_detection         = optional(bool)<br>    requires_session                     = optional(bool)<br><br>    forward_to                        = optional(string)<br>    forward_dead_lettered_messages_to = optional(string)<br><br>    authorizations_custom_name = optional(string)<br>    authorizations = optional(object({<br>      listen = optional(bool, true)<br>      send   = optional(bool, true)<br>      manage = optional(bool, true)<br>    }), {})<br>  }))</pre> | `[]` | no |
| servicebus\_topics | List of objects to create Topics with their options.<pre>name        = Short Topic name.<br>custom_name = Custom name for Azure resource.<br><br>status = The status of the Service Bus Topic. Acceptable values are `Active` or `Disabled`.<br><br>auto_delete_on_idle                     = Duration of the idle interval after which the Topic is automatically deleted, minimum of 5 minutes.<br>default_message_ttl                     = Duration of TTL of messages sent to this Topic if no TTL value is set on the message itself.<br>duplicate_detection_history_time_window = Duration during which duplicates can be detected.<br>max_message_size_in_kilobytes           = Integer value which controls the maximum size of a message allowed on the Topic for `Premium` SKU.<br>max_size_in_megabytes                   = Integer value which controls the size of memory allocated for the Topic.<br><br>enable_batched_operations    = Boolean flag which controls if server-side batched operations are enabled.<br>enable_partitioning          = Boolean flag which controls whether to enable the Topic to be partitioned across multiple message brokers.<br>enable_express               = Boolean flag which controls whether Express Entities are enabled. An express Topic holds a message in memory temporarily before writing it to persistent storage.<br>requires_duplicate_detection = Boolean flag which controls whether the Topic requires duplicate detection.<br>support_ordering             = Boolean flag which controls whether the Topic supports ordering.<br><br>authorizations_custom_name = To override default Topic Authorization Rules names, generated if not set (first with the custom name of the Topic if set, otherwise with Azure CAF).<br>authorizations             = Object with `listen`, `send` and `manage` attributes to create Topics Authorizations Rules.<br><br>subscriptions = List of subscriptions per Topic.</pre> | <pre>list(object({<br>    name        = string<br>    custom_name = optional(string)<br><br>    status = optional(string, "Active")<br><br>    auto_delete_on_idle                     = optional(string)<br>    default_message_ttl                     = optional(string)<br>    duplicate_detection_history_time_window = optional(string)<br>    max_message_size_in_kilobytes           = optional(number)<br>    max_size_in_megabytes                   = optional(number)<br><br>    enable_batched_operations    = optional(bool)<br>    enable_partitioning          = optional(bool)<br>    enable_express               = optional(bool)<br>    requires_duplicate_detection = optional(bool)<br>    support_ordering             = optional(bool)<br><br>    authorizations_custom_name = optional(string)<br>    authorizations = optional(object({<br>      listen = optional(bool, true)<br>      send   = optional(bool, true)<br>      manage = optional(bool, true)<br>    }), {})<br><br>    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription<br>    subscriptions = optional(list(object({<br>      name        = string<br>      custom_name = optional(string)<br><br>      status = optional(string, "Active")<br><br>      auto_delete_on_idle = optional(string)<br>      default_message_ttl = optional(string)<br>      lock_duration       = optional(string)<br>      max_delivery_count  = number<br><br>      enable_batched_operations                 = optional(bool, true)<br>      dead_lettering_on_message_expiration      = optional(bool)<br>      dead_lettering_on_filter_evaluation_error = optional(bool)<br>      requires_session                          = optional(bool)<br><br>      forward_to                        = optional(string)<br>      forward_dead_lettered_messages_to = optional(string)<br>    })), [])<br>  }))</pre> | `[]` | no |
| stack | Project stack name | `string` | n/a | yes |
| subnet\_ids | Subnets to allow access to that Service Bus Namespace. | `list(string)` | `[]` | no |
| trusted\_services\_allowed | If True, then Azure Services that are known and trusted for this resource type are allowed to bypass firewall configuration. | `bool` | `true` | no |
| use\_caf\_naming | Use the Azure CAF naming provider to generate default resource name. `custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Service Bus Namespace outputs. |
| namespace\_listen\_authorization\_rule | Service Bus namespace listen only authorization rule. |
| namespace\_manage\_authorization\_rule | Service Bus namespace manage authorization rule. |
| namespace\_send\_authorization\_rule | Service Bus namespace send only authorization rule. |
| queues | Service Bus queues outputs. |
| queues\_listen\_authorization\_rule | Service Bus queues listen only authorization rules. |
| queues\_manage\_authorization\_rule | Service Bus queues manage authorization rules. |
| queues\_send\_authorization\_rule | Service Bus queues send only authorization rules. |
| topics | Service Bus topics outputs. |
| topics\_listen\_authorization\_rule | Service Bus topics listen only authorization rules. |
| topics\_manage\_authorization\_rule | Service Bus topics manage authorization rules. |
| topics\_send\_authorization\_rule | Service Bus topics send only authorization rules. |
<!-- END_TF_DOCS -->

## Authors

Module managed by [TO THE NEW Pvt. Ltd.](https://github.com/tothenew)

## License

Apache 2 Licensed. See [LICENSE](https://github.com/tothenew/terraform-aws-template/blob/main/LICENSE) for full details.

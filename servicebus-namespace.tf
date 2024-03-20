resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  name                = coalesce(var.namespace_parameters.custom_name, data.azurecaf_name.servicebus_namespace.result)
  location            = var.location
  resource_group_name = var.resource_group_name

  sku                 = var.namespace_parameters.sku
  capacity            = var.namespace_parameters.sku != "Premium" ? 0 : var.namespace_parameters.capacity
  local_auth_enabled  = var.namespace_parameters.local_auth_enabled
  zone_redundant      = var.namespace_parameters.sku != "Premium" ? false : var.namespace_parameters.zone_redundant
  minimum_tls_version = var.namespace_parameters.minimum_tls_version

  public_network_access_enabled = var.namespace_parameters.public_network_access_enabled

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : ["enabled"]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids == "UserAssigned" ? var.identity_ids : null
    }
  }

  tags = merge(
    local.default_tags,
    var.extra_tags,
  )
}


resource "azurerm_servicebus_namespace_authorization_rule" "listen" {
  for_each = toset(var.namespace_authorizations.listen ? ["enabled"] : [])

  name         = var.use_caf_naming ? data.azurecaf_name.servicebus_namespace_auth_rule["listen"].result : "listen-default"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  listen = true
  send   = false
  manage = false
}

# ----------------------------------    Azure Service Bus Authorization Rule Set  -----------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_servicebus_namespace_authorization_rule" "send" {
  for_each = toset(var.namespace_authorizations.send ? ["enabled"] : [])

  name         = var.use_caf_naming ? data.azurecaf_name.servicebus_namespace_auth_rule["send"].result : "send-default"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  listen = false
  send   = true
  manage = false
}

resource "azurerm_servicebus_namespace_authorization_rule" "manage" {
  for_each = toset(var.namespace_authorizations.manage ? ["enabled"] : [])

  name         = var.use_caf_naming ? data.azurecaf_name.servicebus_namespace_auth_rule["manage"].result : "manage-default"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  listen = true
  send   = true
  manage = true
}

# ----------------------------------    Azure Service Bus Network Rule Set  -----------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_servicebus_namespace_network_rule_set" "network_rules" {
  count = var.network_rules_enabled ? 1 : 0

  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  default_action                = var.default_firewall_action
  public_network_access_enabled = var.namespace_parameters.public_network_access_enabled
  trusted_services_allowed      = var.trusted_services_allowed

  dynamic "network_rules" {
    for_each = var.subnet_ids != null ? var.subnet_ids : []
    iterator = subnet
    content {
      subnet_id                            = subnet.value
      ignore_missing_vnet_service_endpoint = false
    }
  }

  ip_rules = var.allowed_cidrs

  lifecycle {
    precondition {
      condition     = !var.network_rules_enabled || (var.network_rules_enabled && var.namespace_parameters.sku == "Premium")
      error_message = "`var.namespace_parameters.sku` must be `Premium` to enable network rules."
    }
  }
}
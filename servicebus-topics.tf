resource "azurerm_servicebus_topic" "topic" {
  for_each = local.topics

  name         = coalesce(each.value.custom_name, data.azurecaf_name.servicebus_topic[each.key].result)
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  status = each.value.status

  auto_delete_on_idle = try(format("PT%sM", tonumber(each.value.auto_delete_on_idle)), each.value.auto_delete_on_idle)
  default_message_ttl = try(format("PT%sM", tonumber(each.value.default_message_ttl)), each.value.default_message_ttl)

  duplicate_detection_history_time_window = try(format("PT%sM", tonumber(each.value.duplicate_detection_history_time_window)), each.value.duplicate_detection_history_time_window)

  enable_batched_operations = each.value.enable_batched_operations
  enable_express            = each.value.enable_express
  enable_partitioning       = var.namespace_parameters.sku != "Premium" ? each.value.enable_partitioning : null

  max_message_size_in_kilobytes = var.namespace_parameters.sku != "Premium" ? null : each.value.max_message_size_in_kilobytes
  max_size_in_megabytes         = each.value.max_size_in_megabytes
  requires_duplicate_detection  = each.value.requires_duplicate_detection
  support_ordering              = each.value.support_ordering
}


resource "azurerm_servicebus_topic_authorization_rule" "listen" {
  for_each = {
    for a in local.topics_auth : format("%s.listen", a.topic) => a if a.rule == "listen" && a.authorizations.listen
  }

  name     = try(format("%s-listen", coalesce(each.value.authorizations_custom_name, each.value.custom_name)), var.use_caf_naming ? data.azurecaf_name.servicebus_topic_auth_rule[each.key].result : "listen-default")
  topic_id = azurerm_servicebus_topic.topic[each.value.topic].id

  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_topic_authorization_rule" "send" {
  for_each = {
    for a in local.topics_auth : format("%s.send", a.topic) => a if a.rule == "send" && a.authorizations.send
  }

  name     = try(format("%s-send", coalesce(each.value.authorizations_custom_name, each.value.custom_name)), var.use_caf_naming ? data.azurecaf_name.servicebus_topic_auth_rule[each.key].result : "send-default")
  topic_id = azurerm_servicebus_topic.topic[each.value.topic].id

  listen = false
  send   = true
  manage = false
}

resource "azurerm_servicebus_topic_authorization_rule" "manage" {
  for_each = {
    for a in local.topics_auth : format("%s.manage", a.topic) => a if a.rule == "manage" && a.authorizations.manage
  }

  name     = try(format("%s-manage", coalesce(each.value.authorizations_custom_name, each.value.custom_name)), var.use_caf_naming ? data.azurecaf_name.servicebus_topic_auth_rule[each.key].result : "manage-default")
  topic_id = azurerm_servicebus_topic.topic[each.value.topic].id

  listen = true
  send   = true
  manage = true
}
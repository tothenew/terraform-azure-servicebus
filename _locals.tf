locals {

  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  default_tags = var.default_tags_enabled ? {
    env   = var.environment
    stack = var.stack
  } : {} 

  queues = try({ for q in var.servicebus_queues : q.name => q }, {})
  topics = try({ for t in var.servicebus_topics : t.name => t }, {})


  queues_auth = flatten([
    for q_name, q in local.queues : [
      for rule in ["listen", "send", "manage"] : {
        queue                      = q_name
        rule                       = rule
        custom_name                = q.custom_name
        authorizations_custom_name = q.authorizations_custom_name
        authorizations             = q.authorizations
      }
    ]
  ])
  topics_auth = flatten([
    for t_name, t in local.topics : [
      for rule in ["listen", "send", "manage"] : {
        topic                      = t_name
        rule                       = rule
        custom_name                = t.custom_name
        authorizations_custom_name = t.authorizations_custom_name
        authorizations             = t.authorizations
      }
    ]
  ])
}
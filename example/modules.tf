## Users can create the resource group here 
resource "azurerm_resource_group" "main" {
  name     = "my-servicebus-rg1" 
  location = "eastus" 
}

module "servicebus" {
  source  = "../" 

  client_name    = "test" 
  environment    = "dev"
  stack          = "ci" 

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  namespace_parameters = {
    sku = "Standard"
  }

  namespace_authorizations = {
    listen = true
    send   = false
  }

  # Network rules
  network_rules_enabled    = false 
  trusted_services_allowed = true
#   allowed_cidrs = [
#     "1.2.3.4/32",
#   ]
#   subnet_ids = [
#     data.azurerm_subnet.example.id,
#   ]

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
    createdBy = "Deepak" 
  }
}
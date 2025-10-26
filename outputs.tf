# Event Hubs Module Outputs

output "eventhubs_namespace_id" {
  description = "ID of the Event Hubs namespace"
  value       = azurerm_eventhub_namespace.this.id
}

output "eventhubs_namespace_name" {
  description = "Name of the Event Hubs namespace"
  value       = azurerm_eventhub_namespace.this.name
}

output "eventhubs_namespace_primary_connection_string" {
  description = "Primary connection string for the Event Hubs namespace"
  value       = azurerm_eventhub_namespace.this.default_primary_connection_string
  sensitive   = true
}

output "eventhubs_namespace_secondary_connection_string" {
  description = "Secondary connection string for the Event Hubs namespace"
  value       = azurerm_eventhub_namespace.this.default_secondary_connection_string
  sensitive   = true
}

output "eventhubs_namespace_primary_key" {
  description = "Primary key for the Event Hubs namespace"
  value       = azurerm_eventhub_namespace.this.default_primary_key
  sensitive   = true
}

output "eventhubs_namespace_secondary_key" {
  description = "Secondary key for the Event Hubs namespace"
  value       = azurerm_eventhub_namespace.this.default_secondary_key
  sensitive   = true
}

output "eventhubs" {
  description = "Map of Event Hubs with their properties"
  value = {
    for eh in azurerm_eventhub.this : eh.name => {
      id                = eh.id
      name              = eh.name
      partition_count   = eh.partition_count
      message_retention = eh.message_retention
    }
  }
}

output "eventhub_authorization_rules" {
  description = "Map of Event Hub authorization rules with their properties"
  value = {
    for rule in azurerm_eventhub_authorization_rule.this : rule.name => {
      id                          = rule.id
      name                        = rule.name
      eventhub                    = rule.eventhub_name
      primary_key                 = rule.primary_key
      secondary_key               = rule.secondary_key
      primary_connection_string   = rule.primary_connection_string
      secondary_connection_string = rule.secondary_connection_string
    }
  }
  sensitive = true
}

output "eventhubs_namespace_auth_rules" {
  description = "Map of namespace authorization rules with their properties"
  value = {
    for rule in azurerm_eventhub_namespace_authorization_rule.this : rule.name => {
      id                          = rule.id
      name                        = rule.name
      primary_key                 = rule.primary_key
      secondary_key               = rule.secondary_key
      primary_connection_string   = rule.primary_connection_string
      secondary_connection_string = rule.secondary_connection_string
    }
  }
  sensitive = true
}

output "consumer_groups" {
  description = "Map of consumer groups with their properties"
  value = {
    for cg in azurerm_eventhub_consumer_group.this : cg.name => {
      id            = cg.id
      name          = cg.name
      eventhub      = cg.eventhub_name
      user_metadata = cg.user_metadata
    }
  }
}

output "schema_groups" {
  description = "Map of schema groups with their properties"
  value = {
    for sg in azurerm_eventhub_namespace_schema_group.this : sg.name => {
      id                   = sg.id
      name                 = sg.name
      schema_compatibility = sg.schema_compatibility
      schema_type          = sg.schema_type
    }
  }
}

output "eventhubs_private_endpoint" {
  description = "Private endpoint configuration"
  value = var.enable_private_endpoint ? {
    id                 = azurerm_private_endpoint.this["namespace"].id
    name               = azurerm_private_endpoint.this["namespace"].name
    private_ip_address = azurerm_private_endpoint.this["namespace"].private_service_connection[0].private_ip_address
  } : null
}

output "eventhubs_private_dns_zone" {
  description = "Private DNS zone configuration"
  value = var.enable_private_endpoint && var.create_private_dns_zone ? {
    id   = azurerm_private_dns_zone.this[0].id
    name = azurerm_private_dns_zone.this[0].name
  } : null
}

output "eventhubs_resource_group_name" {
  description = "Resource group name"
  value       = local.resource_group_name
}

output "eventhubs_location" {
  description = "Azure region"
  value       = local.location
}

output "eventhubs_sku" {
  description = "Event Hubs SKU"
  value       = var.sku
}

output "eventhubs_capacity" {
  description = "Event Hubs capacity"
  value       = var.capacity
}

output "eventhubs_managed_identity_enabled" {
  description = "Whether managed identity is enabled"
  value       = var.enable_managed_identity
}

output "eventhubs_identity" {
  description = "Managed identity configuration"
  value       = var.enable_managed_identity ? azurerm_eventhub_namespace.this.identity : null
}

output "eventhubs_network_rules_enabled" {
  description = "Whether network rules are enabled"
  value       = var.enable_network_rules
}

output "eventhubs_private_endpoint_enabled" {
  description = "Whether private endpoint is enabled"
  value       = var.enable_private_endpoint
}

output "eventhubs_diagnostic_settings_enabled" {
  description = "Whether diagnostic settings are enabled"
  value       = var.enable_diagnostic_settings
}

output "eventhubs_resource_lock_enabled" {
  description = "Whether resource lock is enabled"
  value       = var.enable_resource_lock
}

output "eventhubs_tags" {
  description = "Tags applied to resources"
  value       = local.tags
}
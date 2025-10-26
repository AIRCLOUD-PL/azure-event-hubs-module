# Azure Event Hubs Module
# Creates enterprise-grade Event Hubs namespace with advanced security, monitoring, and compliance features

# Data sources
data "azurerm_client_config" "current" {}

# Local values
locals {
  resource_group_name = var.resource_group_name
  location            = var.location
  location_short      = var.location_short
  environment         = var.environment
  custom_name         = var.custom_name

  # Naming convention
  name_prefix = "eh-${local.custom_name}-${local.location_short}-${local.environment}"

  # Event Hubs namespace name (must be globally unique)
  eventhubs_name = var.eventhubs_name != "" ? var.eventhubs_name : local.name_prefix

  # Resource tags
  tags = merge(
    {
      Environment = local.environment
      Location    = local.location
      Service     = "Event Hubs"
      Module      = "messaging/event-hubs"
      CreatedBy   = "Terraform"
      CreatedOn   = timestamp()
    },
    var.tags
  )

  # Identity configuration
  identity_type = var.enable_managed_identity ? "SystemAssigned" : null

  # Network configuration
  network_rules = var.enable_network_rules ? {
    default_action                 = var.network_default_action
    public_network_access_enabled  = var.public_network_access_enabled
    trusted_service_access_enabled = var.trusted_service_access_enabled
    ip_rules                       = var.ip_rules
    virtual_network_rules          = var.virtual_network_rules
  } : null

  # Event Hubs configuration
  eventhubs = {
    for eh in var.eventhubs : eh.name => {
      name              = eh.name
      partition_count   = lookup(eh, "partition_count", 2)
      message_retention = lookup(eh, "message_retention", 1)
      status            = lookup(eh, "status", "Active")
      capture_description = lookup(eh, "capture_description", null) != null ? {
        enabled             = lookup(eh.capture_description, "enabled", false)
        encoding            = lookup(eh.capture_description, "encoding", "Avro")
        interval_in_seconds = lookup(eh.capture_description, "interval_in_seconds", 300)
        size_limit_in_bytes = lookup(eh.capture_description, "size_limit_in_bytes", 314572800)
        skip_empty_archives = lookup(eh.capture_description, "skip_empty_archives", false)
        destination = lookup(eh.capture_description, "destination", null) != null ? {
          name                = lookup(eh.capture_description.destination, "name", "EventHubArchive.AzureBlockBlob")
          archive_name_format = lookup(eh.capture_description.destination, "archive_name_format", "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}")
          blob_container_name = lookup(eh.capture_description.destination, "blob_container_name", null)
          storage_account_id  = lookup(eh.capture_description.destination, "storage_account_id", null)
        } : null
      } : null
    }
  }

  # Consumer groups configuration
  consumer_groups = flatten([
    for eh in var.eventhubs : [
      for cg in lookup(eh, "consumer_groups", []) : {
        eventhub_name = eh.name
        name          = cg.name
        user_metadata = lookup(cg, "user_metadata", null)
      }
    ]
  ])

  # Authorization rules
  namespace_auth_rules = {
    for rule in var.namespace_authorization_rules : rule.name => {
      name   = rule.name
      listen = lookup(rule, "listen", true)
      send   = lookup(rule, "send", true)
      manage = lookup(rule, "manage", false)
    }
  }

  eventhub_auth_rules = flatten([
    for eh in var.eventhubs : [
      for rule in lookup(eh, "authorization_rules", []) : {
        eventhub_name = eh.name
        name          = rule.name
        listen        = lookup(rule, "listen", true)
        send          = lookup(rule, "send", true)
        manage        = lookup(rule, "manage", false)
      }
    ]
  ])
}

# Resource Group (if not provided externally)
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

# Event Hubs Namespace
resource "azurerm_eventhub_namespace" "this" {
  name                          = local.eventhubs_name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku                           = var.sku
  capacity                      = var.capacity
  dedicated_cluster_id          = var.dedicated_cluster_id
  auto_inflate_enabled          = var.auto_inflate_enabled
  maximum_throughput_units      = var.maximum_throughput_units
  # zone_redundant not supported in azurerm 4.x - handled via sku
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  local_authentication_enabled = var.local_auth_enabled

  dynamic "identity" {
    for_each = local.identity_type != null ? [1] : []
    content {
      type = local.identity_type
    }
  }

  dynamic "network_rulesets" {
    for_each = local.network_rules != null ? [local.network_rules] : []
    content {
      default_action                 = network_rulesets.value.default_action
      public_network_access_enabled  = network_rulesets.value.public_network_access_enabled
      trusted_service_access_enabled = network_rulesets.value.trusted_service_access_enabled

      dynamic "ip_rule" {
        for_each = network_rulesets.value.ip_rules
        content {
          ip_mask = ip_rule.value
          action  = "Allow"
        }
      }

      dynamic "virtual_network_rule" {
        for_each = network_rulesets.value.virtual_network_rules
        content {
          subnet_id                                       = virtual_network_rule.value.subnet_id
          ignore_missing_virtual_network_service_endpoint = virtual_network_rule.value.ignore_missing_virtual_network_service_endpoint
        }
      }
    }
  }

  tags = local.tags

  depends_on = [
    azurerm_resource_group.this
  ]
}

# Event Hubs Namespace Authorization Rules
resource "azurerm_eventhub_namespace_authorization_rule" "this" {
  for_each = local.namespace_auth_rules

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = local.resource_group_name

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
}

# Event Hubs
resource "azurerm_eventhub" "this" {
  for_each = local.eventhubs

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = local.resource_group_name
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
  status              = each.value.status

  dynamic "capture_description" {
    for_each = each.value.capture_description != null ? [each.value.capture_description] : []
    content {
      enabled             = capture_description.value.enabled
      encoding            = capture_description.value.encoding
      interval_in_seconds = capture_description.value.interval_in_seconds
      size_limit_in_bytes = capture_description.value.size_limit_in_bytes
      skip_empty_archives = capture_description.value.skip_empty_archives

      dynamic "destination" {
        for_each = capture_description.value.destination != null ? [capture_description.value.destination] : []
        content {
          name                = destination.value.name
          archive_name_format = destination.value.archive_name_format
          blob_container_name = destination.value.blob_container_name
          storage_account_id  = destination.value.storage_account_id
        }
      }
    }
  }
}

# Event Hub Authorization Rules
resource "azurerm_eventhub_authorization_rule" "this" {
  for_each = {
    for rule in local.eventhub_auth_rules : "${rule.eventhub_name}.${rule.name}" => rule
  }

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = each.value.eventhub_name
  resource_group_name = local.resource_group_name

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
}

# Consumer Groups
resource "azurerm_eventhub_consumer_group" "this" {
  for_each = {
    for cg in local.consumer_groups : "${cg.eventhub_name}.${cg.name}" => cg
  }

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = each.value.eventhub_name
  resource_group_name = local.resource_group_name
  user_metadata       = each.value.user_metadata
}

# Schema Registry
resource "azurerm_eventhub_namespace_schema_group" "this" {
  for_each = var.schema_groups

  name                 = each.value.name
  namespace_id         = azurerm_eventhub_namespace.this.id
  schema_compatibility = each.value.schema_compatibility
  schema_type          = each.value.schema_type
}

# Private Endpoints
resource "azurerm_private_endpoint" "this" {
  for_each = var.enable_private_endpoint ? toset(["namespace"]) : []

  name                = "${local.eventhubs_name}-pe"
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${local.eventhubs_name}-pe-conn"
    private_connection_resource_id = azurerm_eventhub_namespace.this.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  tags = local.tags

  depends_on = [
    azurerm_eventhub_namespace.this
  ]
}

# Private DNS Zone (if private endpoint is enabled)
resource "azurerm_private_dns_zone" "this" {
  count = var.enable_private_endpoint && var.create_private_dns_zone ? 1 : 0

  name                = "privatelink.servicebus.windows.net"
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count = var.enable_private_endpoint && var.create_private_dns_zone ? 1 : 0

  name                  = "${local.eventhubs_name}-dns-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[0].name
  virtual_network_id    = var.private_dns_zone_virtual_network_id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_dns_a_record" "this" {
  count = var.enable_private_endpoint && var.create_private_dns_zone ? 1 : 0

  name                = local.eventhubs_name
  zone_name           = azurerm_private_dns_zone.this[0].name
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.this["namespace"].private_service_connection[0].private_ip_address]

  depends_on = [
    azurerm_private_endpoint.this
  ]
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${local.eventhubs_name}-diagnostics"
  target_resource_id         = azurerm_eventhub_namespace.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_settings.logs
    content {
      category = enabled_log.value.category
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_settings.metrics
    content {
      category = metric.value.category
      enabled  = metric.value.enabled
    }
  }
}

# Resource Lock
resource "azurerm_management_lock" "this" {
  count = var.enable_resource_lock ? 1 : 0

  name       = "${local.eventhubs_name}-lock"
  scope      = azurerm_eventhub_namespace.this.id
  lock_level = var.lock_level
  notes      = "Resource lock for Event Hubs namespace"
}
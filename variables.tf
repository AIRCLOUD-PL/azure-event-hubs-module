# Event Hubs Module Variables

# Resource Configuration
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "location_short" {
  description = "Short name for the location (e.g., 'eus' for East US)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., 'dev', 'test', 'prod')"
  type        = string
}

variable "custom_name" {
  description = "Custom name for the Event Hubs namespace"
  type        = string
}

variable "eventhubs_name" {
  description = "Name of the Event Hubs namespace (must be globally unique). If empty, will be generated from naming convention"
  type        = string
  default     = ""
}

variable "create_resource_group" {
  description = "Whether to create the resource group"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# Event Hubs Configuration
variable "sku" {
  description = "SKU for the Event Hubs namespace (Basic, Standard, Premium, Dedicated)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium", "Dedicated"], var.sku)
    error_message = "SKU must be Basic, Standard, Premium, or Dedicated"
  }
}

variable "capacity" {
  description = "Capacity for the Event Hubs namespace (1-20 for Premium)"
  type        = number
  default     = 1
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 20
    error_message = "Capacity must be between 1 and 20"
  }
}

variable "dedicated_cluster_id" {
  description = "ID of the dedicated Event Hubs cluster"
  type        = string
  default     = null
}

variable "auto_inflate_enabled" {
  description = "Enable auto-inflate for the namespace"
  type        = bool
  default     = false
}

variable "maximum_throughput_units" {
  description = "Maximum throughput units when auto-inflate is enabled (0-20)"
  type        = number
  default     = 0
  validation {
    condition     = var.maximum_throughput_units >= 0 && var.maximum_throughput_units <= 20
    error_message = "Maximum throughput units must be between 0 and 20"
  }
}

variable "zone_redundant" {
  description = "Whether to enable zone redundancy"
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "Minimum TLS version (1.0, 1.1, 1.2)"
  type        = string
  default     = "1.2"
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be 1.0, 1.1, or 1.2"
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  type        = bool
  default     = true
}

variable "local_auth_enabled" {
  description = "Whether local authentication is enabled"
  type        = bool
  default     = true
}

# Identity Configuration
variable "enable_managed_identity" {
  description = "Enable managed identity for the Event Hubs namespace"
  type        = bool
  default     = true
}

# Network Configuration
variable "enable_network_rules" {
  description = "Enable network rules for the Event Hubs namespace"
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "Default action for network rules (Allow, Deny)"
  type        = string
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "Network default action must be Allow or Deny"
  }
}

variable "trusted_service_access_enabled" {
  description = "Whether trusted service access is enabled"
  type        = bool
  default     = false
}

variable "ip_rules" {
  description = "List of IP rules for network access"
  type        = list(string)
  default     = []
}

variable "virtual_network_rules" {
  description = "List of virtual network rules for network access"
  type = list(object({
    subnet_id                                       = string
    ignore_missing_virtual_network_service_endpoint = optional(bool, false)
  }))
  default = []
}

# Event Hubs Configuration
variable "eventhubs" {
  description = "List of Event Hubs to create"
  type = list(object({
    name = string
    authorization_rules = optional(list(object({
      name   = string
      listen = optional(bool, true)
      send   = optional(bool, true)
      manage = optional(bool, false)
    })), [])
    consumer_groups = optional(list(object({
      name          = string
      user_metadata = optional(string, null)
    })), [])
    partition_count   = optional(number, 2)
    message_retention = optional(number, 1)
    status            = optional(string, "Active")
    capture_description = optional(object({
      enabled             = optional(bool, false)
      encoding            = optional(string, "Avro")
      interval_in_seconds = optional(number, 300)
      size_limit_in_bytes = optional(number, 314572800)
      skip_empty_archives = optional(bool, false)
      destination = optional(object({
        name                = optional(string, "EventHubArchive.AzureBlockBlob")
        archive_name_format = optional(string, "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}")
        blob_container_name = string
        storage_account_id  = string
      }), null)
    }), null)
  }))
  default = []
}

# Schema Groups Configuration
variable "schema_groups" {
  description = "Map of schema groups for Event Hubs"
  type = map(object({
    schema_compatibility = string
    schema_type          = string
    group_properties     = optional(map(string), {})
  }))
  default = {}
}

# Authorization Rules
variable "namespace_authorization_rules" {
  description = "List of authorization rules for the Event Hubs namespace"
  type = list(object({
    name   = string
    listen = optional(bool, true)
    send   = optional(bool, true)
    manage = optional(bool, false)
  }))
  default = []
}

# Private Endpoint Configuration
variable "enable_private_endpoint" {
  description = "Enable private endpoint for Event Hubs namespace"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "create_private_dns_zone" {
  description = "Create private DNS zone for private endpoint"
  type        = bool
  default     = false
}

variable "private_dns_zone_virtual_network_id" {
  description = "Virtual network ID for private DNS zone link"
  type        = string
  default     = null
}

# Monitoring Configuration
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Event Hubs namespace"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_settings" {
  description = "Configuration for diagnostic settings"
  type = object({
    logs = list(object({
      category = string
    }))
    metrics = list(object({
      category = string
      enabled  = bool
    }))
  })
  default = {
    logs = [
      {
        category = "ArchiveLogs"
      },
      {
        category = "OperationalLogs"
      },
      {
        category = "AutoScaleLogs"
      }
    ]
    metrics = [
      {
        category = "AllMetrics"
        enabled  = true
      }
    ]
  }
}

# Resource Lock Configuration
variable "enable_resource_lock" {
  description = "Enable resource lock for Event Hubs namespace"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "Level of resource lock (CanNotDelete or ReadOnly)"
  type        = string
  default     = "CanNotDelete"
  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "Lock level must be CanNotDelete or ReadOnly"
  }
}

# Azure Policy Configuration
variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments for Event Hubs"
  type        = bool
  default     = false
}

variable "enable_custom_policies" {
  description = "Enable custom policy assignments for Event Hubs"
  type        = bool
  default     = false
}

variable "enable_policy_initiative" {
  description = "Enable policy initiative assignment for Event Hubs"
  type        = bool
  default     = false
}

variable "policy_initiative_id" {
  description = "ID of the policy initiative to assign"
  type        = string
  default     = "/providers/Microsoft.Authorization/policyDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
}
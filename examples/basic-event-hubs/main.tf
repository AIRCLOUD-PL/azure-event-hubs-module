# Basic Event Hubs Example
# This example demonstrates how to create a basic Azure Event Hubs namespace with event hubs

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-eventhubs-example"
  location = "East US 2"

  tags = {
    Environment = "example"
    Module      = "azure-event-hubs"
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-eventhubs-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "example"
    Module      = "azure-event-hubs"
  }
}

# Azure Event Hubs Module
module "event_hubs" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  location_short      = "eus"
  environment         = "example"
  custom_name         = "demo"

  # Namespace Configuration
  sku      = "Standard"
  capacity = 1

  # Event Hubs
  eventhubs = [
    {
      name              = "orders"
      partition_count   = 4
      message_retention = 7
      status            = "Active"
    },
    {
      name              = "inventory"
      partition_count   = 2
      message_retention = 3
      status            = "Active"
    }
  ]

  # Monitoring
  enable_diagnostic_settings = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    Environment = "example"
    Purpose     = "basic-event-hubs-demo"
  }
}

# Outputs
output "eventhubs_namespace_id" {
  description = "The ID of the Event Hubs namespace"
  value       = module.event_hubs.eventhubs_namespace_id
}

output "eventhubs_namespace_name" {
  description = "The name of the Event Hubs namespace"
  value       = module.event_hubs.eventhubs_namespace_name
}

output "eventhub_ids" {
  description = "Map of Event Hub names to IDs"
  value       = module.event_hubs.eventhub_ids
}

output "primary_connection_string" {
  description = "Primary connection string for the namespace"
  value       = module.event_hubs.primary_connection_string
  sensitive   = true
}
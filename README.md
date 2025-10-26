# Azure Event Hubs Terraform Module

This Terraform module creates enterprise-grade Azure Event Hubs namespaces with advanced security, monitoring, and compliance features.

## Features

- **Event Hubs Namespace**: Create scalable event streaming platform
- **Event Hubs**: Configure individual event hubs with partitions and retention
- **Consumer Groups**: Manage event consumption patterns
- **Network Security**: Virtual network integration and firewall rules
- **Identity Management**: Managed identity and RBAC support
- **Monitoring**: Built-in diagnostic settings and Azure Policy integration

## Usage

```hcl
module "event_hubs" {
  source = "./modules/messaging/event-hubs"

  resource_group_name = "rg-messaging-prod"
  location           = "East US 2"
  environment        = "prod"

  # Namespace Configuration
  sku                 = "Standard"
  capacity           = 1
  zone_redundant     = true

  # Event Hubs
  eventhubs = [
    {
      name                = "orders"
      partition_count     = 4
      message_retention   = 7
      status             = "Active"
    },
    {
      name                = "inventory"
      partition_count     = 2
      message_retention   = 3
      status             = "Active"
    }
  ]

  # Network Security
  enable_network_rules = true
  network_default_action = "Deny"
  ip_rules = ["10.0.0.0/8", "172.16.0.0/12"]

  # Monitoring
  enable_diagnostic_settings = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = "production"
    Project     = "event-streaming"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_policy_definition.eventhubs_network_security](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., prod, dev, test) | `string` | n/a | yes |
| <a name="input_eventhubs_name"></a> [eventhubs\_name](#input\_eventhubs\_name) | Name of the Event Hubs namespace. If empty, will be auto-generated. | `string` | `""` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU for the Event Hubs namespace | `string` | `"Standard"` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Capacity for the Event Hubs namespace | `number` | `1` | no |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Enable zone redundancy | `bool` | `false` | no |
| <a name="input_enable_managed_identity"></a> [enable\_managed\_identity](#input\_enable\_managed\_identity) | Enable managed identity for the namespace | `bool` | `false` | no |
| <a name="input_enable_network_rules"></a> [enable\_network\_rules](#input\_enable\_network\_rules) | Enable network rules for the namespace | `bool` | `false` | no |
| <a name="input_network_default_action"></a> [network\_default\_action](#input\_network\_default\_action) | Default action for network rules | `string` | `"Deny"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Enable public network access | `bool` | `true` | no |
| <a name="input_trusted_service_access_enabled"></a> [trusted\_service\_access\_enabled](#input\_trusted\_service\_access\_enabled) | Enable trusted service access | `bool` | `false` | no |
| <a name="input_ip_rules"></a> [ip\_rules](#input\_ip\_rules) | List of IP rules | `list(string)` | `[]` | no |
| <a name="input_eventhubs"></a> [eventhubs](#input\_eventhubs) | List of event hubs to create | <pre>list(object({<br>    name              = string<br>    partition_count   = optional(number, 4)<br>    message_retention = optional(number, 7)<br>    status           = optional(string, "Active")<br>  }))</pre> | `[]` | no |
| <a name="input_consumer_groups"></a> [consumer\_groups](#input\_consumer\_groups) | List of consumer groups to create | <pre>list(object({<br>    name                = string<br>    eventhub_name       = string<br>    user_metadata      = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | List of authorization rules | <pre>list(object({<br>    name   = string<br>    listen = optional(bool, true)<br>    send   = optional(bool, true)<br>    manage = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID | `string` | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configuration | <pre>object({<br>    logs = list(object({<br>      category = string<br>    }))<br>    metrics = list(object({<br>      category = string<br>      enabled  = bool<br>    }))<br>  })</pre> | <pre>{<br>  "logs": [<br>    {<br>      "category": "ArchiveLogs"<br>    },<br>    {<br>      "category": "OperationalLogs"<br>    }<br>  ],<br>  "metrics": [<br>    {<br>      "category": "AllMetrics",<br>      "enabled": true<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventhubs_namespace_id"></a> [eventhubs\_namespace\_id](#output\_eventhubs\_namespace\_id) | The ID of the Event Hubs namespace |
| <a name="output_eventhubs_namespace_name"></a> [eventhubs\_namespace\_name](#output\_eventhubs\_namespace\_name) | The name of the Event Hubs namespace |
| <a name="output_eventhub_ids"></a> [eventhub\_ids](#output\_eventhub\_ids) | Map of Event Hub names to IDs |
| <a name="output_eventhub_names"></a> [eventhub\_names](#output\_eventhub\_names) | List of Event Hub names |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | Primary connection string for the namespace |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_location"></a> [location](#output\_location) | The location of the Event Hubs namespace |

## Security Features

- **Network Isolation**: Virtual network integration and IP restrictions
- **Access Control**: RBAC and shared access policies
- **Encryption**: Data at rest and in transit encryption
- **Monitoring**: Comprehensive logging and alerting

## Examples

See the [examples](./examples/) directory for complete usage examples:

- [Basic Event Hubs](./examples/basic-event-hubs/)
- [Advanced Security](./examples/advanced-security/)

## Contributing

Please read our [contributing guidelines](../../CONTRIBUTING.md) before submitting pull requests.

## License

This module is licensed under the MIT License. See [LICENSE](../../LICENSE) for details.
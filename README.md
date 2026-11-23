<p align="center">
  <a href="https://aircloud.com.pl"><img src=".github/assets/banner.png" alt="AIRCLOUD: DevOps, cloud and AI engineering" width="100%"></a>
</p>

# azure-event-hubs-module

**Azure Event Hubs Terraform module — parameterised, azurerm 4.x, CI-validated.**

[![CI](https://github.com/AIRCLOUD-PL/azure-event-hubs-module/actions/workflows/ci.yml/badge.svg)](https://github.com/AIRCLOUD-PL/azure-event-hubs-module/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/AIRCLOUD-PL/azure-event-hubs-module?sort=semver)](https://github.com/AIRCLOUD-PL/azure-event-hubs-module/releases)

This Terraform module creates enterprise-grade Azure Event Hubs namespaces with advanced security, monitoring, and compliance features.

## Features

- **Event Hubs Namespace**: Create scalable event streaming platform
- **Event Hubs**: Configure individual event hubs with partitions and retention
- **Consumer Groups**: Manage event consumption patterns
- **Network Security**: Virtual network integration and firewall rules
- **Identity Management**: Managed identity and RBAC support
- **Monitoring**: Built-in diagnostic settings and Azure Policy integration

## Usage

Pin the module to a release tag:

```hcl
module "event_hubs" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-event-hubs-module.git?ref=v1.0.0"

  # required inputs
  custom_name         = "..."
  environment         = "..."
  location            = "..."
  location_short      = "..."
  resource_group_name = "..."
}
```

All inputs and outputs are listed in the generated reference below ([Inputs](#inputs), [Outputs](#outputs)). Worked examples live in [`examples/`](examples/).

```hcl
module "event_hubs" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-event-hubs-module.git?ref=v1.0.0"

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

## Security Features

- **Network Isolation**: Virtual network integration and IP restrictions
- **Access Control**: RBAC and shared access policies
- **Encryption**: Data at rest and in transit encryption
- **Monitoring**: Comprehensive logging and alerting

## Examples

See the [examples](./examples/) directory for complete usage examples:

- [Basic Event Hubs](./examples/basic-event-hubs/)
- [Advanced Security](examples/)

## Contributing

Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_consumer_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_eventhub_namespace_schema_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_schema_group) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_dns_a_record.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group_policy_assignment.eventhubs_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.eventhubs_initiative](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.eventhubs_security](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_remediation.eventhubs_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_remediation) | resource |
| [azurerm_resource_group_policy_remediation.eventhubs_initiative](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_remediation) | resource |
| [azurerm_resource_group_policy_remediation.eventhubs_security](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_remediation) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_inflate_enabled"></a> [auto\_inflate\_enabled](#input\_auto\_inflate\_enabled) | Enable auto-inflate for the namespace | `bool` | `false` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Capacity for the Event Hubs namespace (1-20 for Premium) | `number` | `1` | no |
| <a name="input_create_private_dns_zone"></a> [create\_private\_dns\_zone](#input\_create\_private\_dns\_zone) | Create private DNS zone for private endpoint | `bool` | `false` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Whether to create the resource group | `bool` | `false` | no |
| <a name="input_custom_name"></a> [custom\_name](#input\_custom\_name) | Custom name for the Event Hubs namespace | `string` | n/a | yes |
| <a name="input_dedicated_cluster_id"></a> [dedicated\_cluster\_id](#input\_dedicated\_cluster\_id) | ID of the dedicated Event Hubs cluster | `string` | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Configuration for diagnostic settings | <pre>object({<br/>    logs = list(object({<br/>      category = string<br/>    }))<br/>    metrics = list(object({<br/>      category = string<br/>      enabled  = bool<br/>    }))<br/>  })</pre> | <pre>{<br/>  "logs": [<br/>    {<br/>      "category": "ArchiveLogs"<br/>    },<br/>    {<br/>      "category": "OperationalLogs"<br/>    },<br/>    {<br/>      "category": "AutoScaleLogs"<br/>    }<br/>  ],<br/>  "metrics": [<br/>    {<br/>      "category": "AllMetrics",<br/>      "enabled": true<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_enable_custom_policies"></a> [enable\_custom\_policies](#input\_enable\_custom\_policies) | Enable custom policy assignments for Event Hubs | `bool` | `false` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings for Event Hubs namespace | `bool` | `false` | no |
| <a name="input_enable_managed_identity"></a> [enable\_managed\_identity](#input\_enable\_managed\_identity) | Enable managed identity for the Event Hubs namespace | `bool` | `true` | no |
| <a name="input_enable_network_rules"></a> [enable\_network\_rules](#input\_enable\_network\_rules) | Enable network rules for the Event Hubs namespace | `bool` | `false` | no |
| <a name="input_enable_policy_assignments"></a> [enable\_policy\_assignments](#input\_enable\_policy\_assignments) | Enable Azure Policy assignments for Event Hubs | `bool` | `false` | no |
| <a name="input_enable_policy_initiative"></a> [enable\_policy\_initiative](#input\_enable\_policy\_initiative) | Enable policy initiative assignment for Event Hubs | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Enable private endpoint for Event Hubs namespace | `bool` | `false` | no |
| <a name="input_enable_resource_lock"></a> [enable\_resource\_lock](#input\_enable\_resource\_lock) | Enable resource lock for Event Hubs namespace | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., 'dev', 'test', 'prod') | `string` | n/a | yes |
| <a name="input_eventhubs"></a> [eventhubs](#input\_eventhubs) | List of Event Hubs to create | <pre>list(object({<br/>    name = string<br/>    authorization_rules = optional(list(object({<br/>      name   = string<br/>      listen = optional(bool, true)<br/>      send   = optional(bool, true)<br/>      manage = optional(bool, false)<br/>    })), [])<br/>    consumer_groups = optional(list(object({<br/>      name          = string<br/>      user_metadata = optional(string, null)<br/>    })), [])<br/>    partition_count   = optional(number, 2)<br/>    message_retention = optional(number, 1)<br/>    status            = optional(string, "Active")<br/>    capture_description = optional(object({<br/>      enabled             = optional(bool, false)<br/>      encoding            = optional(string, "Avro")<br/>      interval_in_seconds = optional(number, 300)<br/>      size_limit_in_bytes = optional(number, 314572800)<br/>      skip_empty_archives = optional(bool, false)<br/>      destination = optional(object({<br/>        name                = optional(string, "EventHubArchive.AzureBlockBlob")<br/>        archive_name_format = optional(string, "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}")<br/>        blob_container_name = string<br/>        storage_account_id  = string<br/>      }), null)<br/>    }), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_eventhubs_name"></a> [eventhubs\_name](#input\_eventhubs\_name) | Name of the Event Hubs namespace (must be globally unique). If empty, will be generated from naming convention | `string` | `""` | no |
| <a name="input_ip_rules"></a> [ip\_rules](#input\_ip\_rules) | List of IP rules for network access | `list(string)` | `[]` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether local authentication is enabled | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short name for the location (e.g., 'eus' for East US) | `string` | n/a | yes |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | Level of resource lock (CanNotDelete or ReadOnly) | `string` | `"CanNotDelete"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for diagnostic settings | `string` | `null` | no |
| <a name="input_maximum_throughput_units"></a> [maximum\_throughput\_units](#input\_maximum\_throughput\_units) | Maximum throughput units when auto-inflate is enabled (0-20) | `number` | `0` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version (1.0, 1.1, 1.2) | `string` | `"1.2"` | no |
| <a name="input_namespace_authorization_rules"></a> [namespace\_authorization\_rules](#input\_namespace\_authorization\_rules) | List of authorization rules for the Event Hubs namespace | <pre>list(object({<br/>    name   = string<br/>    listen = optional(bool, true)<br/>    send   = optional(bool, true)<br/>    manage = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_network_default_action"></a> [network\_default\_action](#input\_network\_default\_action) | Default action for network rules (Allow, Deny) | `string` | `"Deny"` | no |
| <a name="input_policy_initiative_id"></a> [policy\_initiative\_id](#input\_policy\_initiative\_id) | ID of the policy initiative to assign | `string` | `"/providers/Microsoft.Authorization/policyDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"` | no |
| <a name="input_private_dns_zone_virtual_network_id"></a> [private\_dns\_zone\_virtual\_network\_id](#input\_private\_dns\_zone\_virtual\_network\_id) | Virtual network ID for private DNS zone link | `string` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for private endpoint | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_schema_groups"></a> [schema\_groups](#input\_schema\_groups) | Map of schema groups for Event Hubs | <pre>map(object({<br/>    schema_compatibility = string<br/>    schema_type          = string<br/>    group_properties     = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU for the Event Hubs namespace (Basic, Standard, Premium, Dedicated) | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for resources | `map(string)` | `{}` | no |
| <a name="input_trusted_service_access_enabled"></a> [trusted\_service\_access\_enabled](#input\_trusted\_service\_access\_enabled) | Whether trusted service access is enabled | `bool` | `false` | no |
| <a name="input_virtual_network_rules"></a> [virtual\_network\_rules](#input\_virtual\_network\_rules) | List of virtual network rules for network access | <pre>list(object({<br/>    subnet_id                                       = string<br/>    ignore_missing_virtual_network_service_endpoint = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Whether to enable zone redundancy | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_consumer_groups"></a> [consumer\_groups](#output\_consumer\_groups) | Map of consumer groups with their properties |
| <a name="output_eventhub_authorization_rules"></a> [eventhub\_authorization\_rules](#output\_eventhub\_authorization\_rules) | Map of Event Hub authorization rules with their properties |
| <a name="output_eventhubs"></a> [eventhubs](#output\_eventhubs) | Map of Event Hubs with their properties |
| <a name="output_eventhubs_capacity"></a> [eventhubs\_capacity](#output\_eventhubs\_capacity) | Event Hubs capacity |
| <a name="output_eventhubs_diagnostic_settings_enabled"></a> [eventhubs\_diagnostic\_settings\_enabled](#output\_eventhubs\_diagnostic\_settings\_enabled) | Whether diagnostic settings are enabled |
| <a name="output_eventhubs_identity"></a> [eventhubs\_identity](#output\_eventhubs\_identity) | Managed identity configuration |
| <a name="output_eventhubs_location"></a> [eventhubs\_location](#output\_eventhubs\_location) | Azure region |
| <a name="output_eventhubs_managed_identity_enabled"></a> [eventhubs\_managed\_identity\_enabled](#output\_eventhubs\_managed\_identity\_enabled) | Whether managed identity is enabled |
| <a name="output_eventhubs_namespace_auth_rules"></a> [eventhubs\_namespace\_auth\_rules](#output\_eventhubs\_namespace\_auth\_rules) | Map of namespace authorization rules with their properties |
| <a name="output_eventhubs_namespace_id"></a> [eventhubs\_namespace\_id](#output\_eventhubs\_namespace\_id) | ID of the Event Hubs namespace |
| <a name="output_eventhubs_namespace_name"></a> [eventhubs\_namespace\_name](#output\_eventhubs\_namespace\_name) | Name of the Event Hubs namespace |
| <a name="output_eventhubs_namespace_primary_connection_string"></a> [eventhubs\_namespace\_primary\_connection\_string](#output\_eventhubs\_namespace\_primary\_connection\_string) | Primary connection string for the Event Hubs namespace |
| <a name="output_eventhubs_namespace_primary_key"></a> [eventhubs\_namespace\_primary\_key](#output\_eventhubs\_namespace\_primary\_key) | Primary key for the Event Hubs namespace |
| <a name="output_eventhubs_namespace_secondary_connection_string"></a> [eventhubs\_namespace\_secondary\_connection\_string](#output\_eventhubs\_namespace\_secondary\_connection\_string) | Secondary connection string for the Event Hubs namespace |
| <a name="output_eventhubs_namespace_secondary_key"></a> [eventhubs\_namespace\_secondary\_key](#output\_eventhubs\_namespace\_secondary\_key) | Secondary key for the Event Hubs namespace |
| <a name="output_eventhubs_network_rules_enabled"></a> [eventhubs\_network\_rules\_enabled](#output\_eventhubs\_network\_rules\_enabled) | Whether network rules are enabled |
| <a name="output_eventhubs_private_dns_zone"></a> [eventhubs\_private\_dns\_zone](#output\_eventhubs\_private\_dns\_zone) | Private DNS zone configuration |
| <a name="output_eventhubs_private_endpoint"></a> [eventhubs\_private\_endpoint](#output\_eventhubs\_private\_endpoint) | Private endpoint configuration |
| <a name="output_eventhubs_private_endpoint_enabled"></a> [eventhubs\_private\_endpoint\_enabled](#output\_eventhubs\_private\_endpoint\_enabled) | Whether private endpoint is enabled |
| <a name="output_eventhubs_resource_group_name"></a> [eventhubs\_resource\_group\_name](#output\_eventhubs\_resource\_group\_name) | Resource group name |
| <a name="output_eventhubs_resource_lock_enabled"></a> [eventhubs\_resource\_lock\_enabled](#output\_eventhubs\_resource\_lock\_enabled) | Whether resource lock is enabled |
| <a name="output_eventhubs_sku"></a> [eventhubs\_sku](#output\_eventhubs\_sku) | Event Hubs SKU |
| <a name="output_eventhubs_tags"></a> [eventhubs\_tags](#output\_eventhubs\_tags) | Tags applied to resources |
| <a name="output_schema_groups"></a> [schema\_groups](#output\_schema\_groups) | Map of schema groups with their properties |
<!-- END_TF_DOCS -->

---

## Part of the AIRCLOUD Azure module catalog

Browse all modules with usage snippets in the [module catalog](https://aircloud-pl.github.io/) or on [github.com/AIRCLOUD-PL](https://github.com/AIRCLOUD-PL). Built and maintained by [AIRCLOUD](https://aircloud.com.pl): DevOps, cloud and AI engineering. Need a hand with Azure landing zones or platform engineering? See [aircloud.com.pl/consulting](https://aircloud.com.pl/consulting).

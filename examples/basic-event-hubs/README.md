# Basic Event Hubs Example

This example demonstrates how to create a basic Azure Event Hubs namespace with multiple event hubs for event streaming.

## Overview

This example creates:
- A resource group
- A Log Analytics workspace for monitoring
- An Event Hubs namespace with Standard SKU
- Two event hubs: "orders" and "inventory" with different configurations
- Diagnostic settings for monitoring

## Architecture

```
Event Hubs Namespace (Standard)
├── Event Hub: orders
│   ├── 4 partitions
│   └── 7-day retention
├── Event Hub: inventory
│   ├── 2 partitions
│   └── 3-day retention
└── Log Analytics Workspace
```

## Usage

1. Navigate to this directory:
   ```bash
   cd examples/basic-event-hubs
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. Clean up when done:
   ```bash
   terraform destroy
   ```

## Configuration

The Event Hubs namespace is configured with:
- **SKU**: Standard tier for production workloads
- **Capacity**: 1 unit (can be scaled as needed)
- **Event Hubs**: Two hubs with different partition counts and retention policies
- **Monitoring**: Full diagnostic logging to Log Analytics

## Event Hub Details

- **orders**: High-throughput event hub with 4 partitions for order processing
- **inventory**: Lower-throughput hub with 2 partitions for inventory updates

## Security Features

- Namespace-level access control
- Diagnostic logging for security monitoring
- Resource tagging for governance

## Outputs

- `eventhubs_namespace_id`: The resource ID of the Event Hubs namespace
- `eventhubs_namespace_name`: The name of the Event Hubs namespace
- `eventhub_ids`: Map of Event Hub names to their resource IDs
- `primary_connection_string`: Connection string for accessing the namespace (sensitive)

## Next Steps

- Explore the [advanced security example](../advanced-security/) for network isolation and access control
- Review the main module [README](../../README.md) for all available options
- Consider adding consumer groups and authorization rules for production use
# Event Hubs Module Azure Policies

# Azure Policy Assignments for Event Hubs Security and Compliance
resource "azurerm_resource_group_policy_assignment" "eventhubs_security" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "eventhubs-security-baseline"
  resource_group_id    = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.existing[0].id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8" # Azure Security Benchmark

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })

  depends_on = [
    azurerm_eventhub_namespace.this
  ]
}

# Custom Policy for Event Hubs Encryption
resource "azurerm_resource_group_policy_assignment" "eventhubs_encryption" {
  count = var.enable_custom_policies ? 1 : 0

  name                 = "eventhubs-encryption-policy"
  resource_group_id    = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.existing[0].id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/5c5e54f6-0949-4d7e-a539-77a3034c55fa" # Storage accounts should use customer-managed key for encryption

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })

  depends_on = [
    azurerm_eventhub_namespace.this
  ]
}

# Policy Initiative for Event Hubs
resource "azurerm_resource_group_policy_assignment" "eventhubs_initiative" {
  count = var.enable_policy_initiative ? 1 : 0

  name                 = "eventhubs-compliance-initiative"
  resource_group_id    = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.existing[0].id
  policy_definition_id = var.policy_initiative_id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })

  depends_on = [
    azurerm_eventhub_namespace.this
  ]
}

# Data source for existing resource group (when not creating)
data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

# Remediation tasks for policy assignments
resource "azurerm_resource_group_policy_remediation" "eventhubs_security" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "eventhubs-security-remediation"
  resource_group_id    = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.existing[0].id
  policy_assignment_id = azurerm_resource_group_policy_assignment.eventhubs_security[0].id

  depends_on = [
    azurerm_resource_group_policy_assignment.eventhubs_security
  ]
}

resource "azurerm_resource_group_policy_remediation" "eventhubs_encryption" {
  count = var.enable_custom_policies ? 1 : 0

  name                 = "eventhubs-encryption-remediation"
  resource_group_id    = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.existing[0].id
  policy_assignment_id = azurerm_resource_group_policy_assignment.eventhubs_encryption[0].id

  depends_on = [
    azurerm_resource_group_policy_assignment.eventhubs_encryption
  ]
}

resource "azurerm_resource_group_policy_remediation" "eventhubs_initiative" {
  count = var.enable_policy_initiative ? 1 : 0

  name                 = "eventhubs-initiative-remediation"
  resource_group_id    = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.existing[0].id
  policy_assignment_id = azurerm_resource_group_policy_assignment.eventhubs_initiative[0].id

  depends_on = [
    azurerm_resource_group_policy_assignment.eventhubs_initiative
  ]
}
package test

import (
	"testing"
	"fmt"
	"strings"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEventHubsEnterprise(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueId := random.UniqueId()
	location := "East US"
	resourceGroupName := fmt.Sprintf("rg-eh-test-%s", uniqueId)
	namespaceName := fmt.Sprintf("eh-test-%s", uniqueId)

	// Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../",

		Vars: map[string]interface{}{
			"resource_group_name": resourceGroupName,
			"location": location,
			"location_short": "eus",
			"environment": "test",
			"custom_name": strings.Replace(namespaceName, "eh-test-", "", 1),

			// Event Hubs configuration
			"sku": "Standard",
			"capacity": 1,
			"minimum_tls_version": "1.2",
			"public_network_access_enabled": true,
			"local_auth_enabled": true,

			// Identity
			"enable_managed_identity": true,

			// Event Hubs
			"eventhubs": []map[string]interface{}{
				{
					"name": "test-eventhub",
					"authorization_rules": []map[string]interface{}{
						{
							"name": "test-eh-rule",
							"listen": true,
							"send": true,
							"manage": false,
						},
					},
					"consumer_groups": []map[string]interface{}{
						{
							"name": "test-consumer-group",
							"user_metadata": "test metadata",
						},
					},
					"partition_count": 2,
					"message_retention": 1,
					"status": "Active",
				},
			},

			// Schema groups
			"schema_groups": map[string]interface{}{
				"test-schema-group": map[string]interface{}{
					"schema_compatibility": "Forward",
					"schema_type": "Avro",
					"group_properties": map[string]interface{}{
						"serdes.format": "avro",
					},
				},
			},

			// Namespace authorization rules
			"namespace_authorization_rules": []map[string]interface{}{
				{
					"name": "test-namespace-rule",
					"listen": true,
					"send": true,
					"manage": false,
				},
			},

			// Disable enterprise features for test
			"enable_network_rules": false,
			"enable_private_endpoint": false,
			"enable_diagnostic_settings": false,
			"enable_policy_assignments": false,
			"enable_custom_policies": false,
			"enable_policy_initiative": false,
			"enable_resource_lock": false,
		},

		NoColor: true,
	}

	// Clean up resources in the end
	defer terraform.Destroy(t, terraformOptions)
	defer azure.DeleteResourceGroupE(t, resourceGroupName)

	// Create resource group
	azure.CreateResourceGroupE(t, resourceGroupName, location)

	// Deploy Event Hubs namespace
	terraform.InitAndApply(t, terraformOptions)

	// Test Event Hubs namespace exists and is configured correctly
	namespace := azure.GetEventHubNamespaceE(t, resourceGroupName, namespaceName)
	assert.NotNil(t, namespace, "Event Hubs namespace should exist")
	assert.Equal(t, namespaceName, *namespace.Name, "Event Hubs namespace name should match")
	assert.Equal(t, "Standard", *namespace.Sku.Name, "SKU should match")

	// Test outputs
	namespaceId := terraform.Output(t, terraformOptions, "eventhubs_namespace_id")
	assert.NotEmpty(t, namespaceId, "Event Hubs namespace ID should not be empty")

	namespaceNameOutput := terraform.Output(t, terraformOptions, "eventhubs_namespace_name")
	assert.Equal(t, namespaceName, namespaceNameOutput, "Event Hubs namespace name should match")

	// Test Event Hubs
	eventhubs := terraform.OutputMap(t, terraformOptions, "eventhubs")
	assert.Contains(t, eventhubs, "test-eventhub", "Should contain test-eventhub")

	// Test consumer groups
	consumerGroups := terraform.OutputMap(t, terraformOptions, "consumer_groups")
	assert.Contains(t, consumerGroups, "test-consumer-group", "Should contain test-consumer-group")

	// Test schema groups
	schemaGroups := terraform.OutputMap(t, terraformOptions, "schema_groups")
	assert.Contains(t, schemaGroups, "test-schema-group", "Should contain test-schema-group")

	// Test authorization rules
	namespaceAuthRules := terraform.OutputMap(t, terraformOptions, "eventhubs_namespace_auth_rules")
	assert.Contains(t, namespaceAuthRules, "test-namespace-rule", "Should contain namespace auth rule")

	eventhubAuthRules := terraform.OutputMap(t, terraformOptions, "eventhub_authorization_rules")
	assert.Contains(t, eventhubAuthRules, "test-eh-rule", "Should contain eventhub auth rule")

	// Test identity configuration
	identity := terraform.Output(t, terraformOptions, "eventhubs_identity")
	assert.NotNil(t, identity, "Identity should be configured")

	managedIdentityEnabled := terraform.Output(t, terraformOptions, "eventhubs_managed_identity_enabled")
	assert.Equal(t, "true", managedIdentityEnabled, "Managed identity should be enabled")

	// Test SKU and capacity
	sku := terraform.Output(t, terraformOptions, "eventhubs_sku")
	assert.Equal(t, "Standard", sku, "SKU should match")

	capacity := terraform.Output(t, terraformOptions, "eventhubs_capacity")
	assert.Equal(t, "1", capacity, "Capacity should match")
}

func TestEventHubsPremium(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueId := random.UniqueId()
	location := "East US"
	resourceGroupName := fmt.Sprintf("rg-eh-premium-test-%s", uniqueId)
	namespaceName := fmt.Sprintf("eh-premium-test-%s", uniqueId)

	// Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../",

		Vars: map[string]interface{}{
			"resource_group_name": resourceGroupName,
			"location": location,
			"location_short": "eus",
			"environment": "test",
			"custom_name": strings.Replace(namespaceName, "eh-premium-test-", "", 1),

			// Premium SKU configuration
			"sku": "Premium",
			"capacity": 2,
			"auto_inflate_enabled": true,
			"maximum_throughput_units": 4,
			"zone_redundant": false,
			"minimum_tls_version": "1.2",

			// Identity
			"enable_managed_identity": true,

			// Event Hubs with capture
			"eventhubs": []map[string]interface{}{
				{
					"name": "premium-eventhub",
					"partition_count": 4,
					"message_retention": 7,
					"capture_description": map[string]interface{}{
						"enabled": true,
						"encoding": "Avro",
						"interval_in_seconds": 300,
						"size_limit_in_bytes": 314572800,
						"skip_empty_archives": true,
						"destination": map[string]interface{}{
							"name": "EventHubArchive.AzureBlockBlob",
							"archive_name_format": "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}",
							"blob_container_name": "eventhub-capture",
							"storage_account_id": "/subscriptions/test/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/teststorage",
						},
					},
				},
			},

			// Disable other features for test
			"enable_network_rules": false,
			"enable_private_endpoint": false,
			"enable_diagnostic_settings": false,
			"enable_policy_assignments": false,
			"enable_custom_policies": false,
			"enable_policy_initiative": false,
			"enable_resource_lock": false,
		},

		NoColor: true,
	}

	// Clean up resources in the end
	defer terraform.Destroy(t, terraformOptions)
	defer azure.DeleteResourceGroupE(t, resourceGroupName)

	// Create resource group
	azure.CreateResourceGroupE(t, resourceGroupName, location)

	// Deploy Event Hubs namespace
	terraform.InitAndApply(t, terraformOptions)

	// Test Premium SKU configuration
	namespace := azure.GetEventHubNamespaceE(t, resourceGroupName, namespaceName)
	assert.NotNil(t, namespace, "Event Hubs namespace should exist")
	assert.Equal(t, "Premium", *namespace.Sku.Name, "SKU should be Premium")
	assert.Equal(t, int32(2), *namespace.Sku.Capacity, "Capacity should be 2")

	// Test outputs
	sku := terraform.Output(t, terraformOptions, "eventhubs_sku")
	assert.Equal(t, "Premium", sku, "SKU should match")

	capacity := terraform.Output(t, terraformOptions, "eventhubs_capacity")
	assert.Equal(t, "2", capacity, "Capacity should match")
}

func TestEventHubsValidation(t *testing.T) {
	t.Parallel()

	// Test invalid SKU
	t.Run("InvalidSKU", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"resource_group_name": "rg-test",
				"location": "East US",
				"location_short": "eus",
				"environment": "test",
				"custom_name": "test",
				"sku": "Invalid",
			},
			NoColor: true,
		}

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		require.Error(t, err, "Should fail with invalid SKU")
		assert.Contains(t, err.Error(), "invalid", "Error should mention invalid SKU")
	})

	// Test invalid capacity
	t.Run("InvalidCapacity", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"resource_group_name": "rg-test",
				"location": "East US",
				"location_short": "eus",
				"environment": "test",
				"custom_name": "test",
				"sku": "Premium",
				"capacity": 25, // Invalid capacity
			},
			NoColor: true,
		}

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		require.Error(t, err, "Should fail with invalid capacity")
		assert.Contains(t, err.Error(), "invalid", "Error should mention invalid capacity")
	})

	// Test invalid TLS version
	t.Run("InvalidTLSVersion", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"resource_group_name": "rg-test",
				"location": "East US",
				"location_short": "eus",
				"environment": "test",
				"custom_name": "test",
				"minimum_tls_version": "0.9",
			},
			NoColor: true,
		}

		_, err := terraform.InitAndPlanE(t, terraformOptions)
		require.Error(t, err, "Should fail with invalid TLS version")
		assert.Contains(t, err.Error(), "invalid", "Error should mention invalid TLS version")
	})
}
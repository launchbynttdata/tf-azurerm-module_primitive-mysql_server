package testimpl

import (
	"context"
	"os"
	"strconv"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	armmysql "github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/mysql/armmysqlflexibleservers"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestmysqlServer(t *testing.T, ctx types.TestContext) {
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Unable to get credentials: %e\n", err)
	}

	options := arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{
			Cloud: cloud.AzurePublic,
		},
	}

	armmysqlClient, err := armmysql.NewServersClient(subscriptionId, credential, &options)
	if err != nil {
		t.Fatalf("Error getting mysql client: %v", err)
	}

	resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
	mysqlName := terraform.Output(t, ctx.TerratestTerraformOptions(), "mysql_name")

	mysqlServer, err := armmysqlClient.Get(context.Background(), resourceGroupName, mysqlName, nil)
	if err != nil {
		t.Fatalf("Error getting mysql server: %v", err)
	}

	t.Run("doesmysqlServerExist", func(t *testing.T) {
		assert.Equal(t, mysqlName, *mysqlServer.Name)
	})

	t.Run("ismysqlServerStorageConfigured", func(t *testing.T) {
		ctx.EnabledOnlyForTests(t, "specific_storage_and_window")
		mysqlStorage := terraform.OutputMap(t, ctx.TerratestTerraformOptions(), "mysql_storage")
		auto_grow := "Disabled"

		if mysqlStorage["auto_grow_enabled"] == "true" {
			auto_grow = "Enabled"
		}

		assert.Equal(t, mysqlStorage["iops"], decimal(mysqlServer.Properties.Storage.Iops), "Expected IOPS to be %s, but got %d", mysqlStorage["iops"], decimal(mysqlServer.Properties.Storage.Iops))
		assert.Equal(t, mysqlStorage["size_gb"], decimal(mysqlServer.Properties.Storage.StorageSizeGB), "Expected storage size to be %s, but got %d", mysqlStorage["size_gb"], decimal(mysqlServer.Properties.Storage.StorageSizeGB))
		assert.Equal(t, auto_grow, string(*mysqlServer.Properties.Storage.AutoGrow), "Expected auto grow to be %s, but got %s", auto_grow, string(*mysqlServer.Properties.Storage.AutoGrow))
	})

	t.Run("ismysqlServerMaintenanceWindowConfigured", func(t *testing.T) {
		ctx.EnabledOnlyForTests(t, "specific_storage_and_window")
		maintenance_window := terraform.OutputMap(t, ctx.TerratestTerraformOptions(), "mysql_maintenance_window")

		assert.Equal(t, "Enabled", string(*mysqlServer.Properties.MaintenanceWindow.CustomWindow))
		assert.Equal(t, maintenance_window["day_of_week"], decimal(mysqlServer.Properties.MaintenanceWindow.DayOfWeek), "Expected day of week to be %s, but got %d", maintenance_window["day_of_week"], decimal(mysqlServer.Properties.MaintenanceWindow.DayOfWeek))
		assert.Equal(t, maintenance_window["start_hour"], decimal(mysqlServer.Properties.MaintenanceWindow.StartHour), "Expected start hour to be %s, but got %d", maintenance_window["start_hour"], decimal(mysqlServer.Properties.MaintenanceWindow.StartHour))
		assert.Equal(t, maintenance_window["start_minute"], decimal(mysqlServer.Properties.MaintenanceWindow.StartMinute), "Expected start minute to be %s, but got %d", maintenance_window["start_minute"], decimal(mysqlServer.Properties.MaintenanceWindow.StartMinute))
	})

	t.Run("areDefaultSettingsActive", func(t *testing.T) {
		ctx.EnabledOnlyForTests(t, "default_settings")
		assert.Equal(t, "Enabled", string(*mysqlServer.Properties.Storage.AutoGrow), "Auto grow should be enabled")
		assert.Equal(t, "Disabled", string(*mysqlServer.Properties.MaintenanceWindow.CustomWindow), "Custom maintenance window should be disabled")
	})
}

func decimal(i *int32) string {
	return strconv.FormatInt(int64(*i), 10)
}

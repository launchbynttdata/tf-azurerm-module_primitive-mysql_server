package testimpl

import (
	"context"
	"os"
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

	t.Run("doesmysqlServerExist", func(t *testing.T) {
		resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
		mysqlName := terraform.Output(t, ctx.TerratestTerraformOptions(), "mysql_name")

		mysqlServer, err := armmysqlClient.Get(context.Background(), resourceGroupName, mysqlName, nil)
		if err != nil {
			t.Fatalf("Error getting mysql server: %v", err)
		}

		assert.Equal(t, mysqlName, *mysqlServer.Name)
	})
}

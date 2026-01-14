# ZavaStorefront Infrastructure

This directory contains the Bicep infrastructure-as-code templates for deploying the ZavaStorefront application to Azure.

## Structure

- `main.bicep` - Root orchestration template that deploys all resources
- `main.parameters.json` - Parameter file with default configuration values
- `modules/` - Reusable Bicep modules (if needed for modular deployments)

## Resources Deployed

- **Azure Container Registry (ACR)** - Stores container images
- **App Service Plan** - Linux-based hosting plan
- **App Service** - Hosts the containerized web application
- **Application Insights** - Monitors application performance and health
- **Log Analytics Workspace** - Collects logs for analysis
- **Managed Identity & Role Assignment** - Enables App Service to pull images from ACR securely

## Deployment

### Using Azure Developer CLI (AZD)

```bash
# Initialize (one-time setup)
azd init

# Preview infrastructure
azd provision --preview

# Deploy infrastructure and application
azd up
```

### Using Azure CLI Directly

```bash
# Set variables
RESOURCE_GROUP="rg-zavastore-dev"
LOCATION="westus3"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Deploy infrastructure
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters main.parameters.json
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `location` | resourceGroup().location | Azure region for resources |
| `environment` | dev | Environment name (dev, staging, prod) |
| `projectName` | zavastore | Project name for resource naming |
| `acrSku` | Basic | Azure Container Registry SKU |
| `appServiceSku` | B1 | App Service Plan SKU |

## Outputs

The deployment produces the following outputs:

- `acrName` - Azure Container Registry name
- `acrLoginServer` - ACR login server URL
- `appServiceName` - App Service name
- `appServiceUrl` - App Service public URL
- `appInsightsInstrumentationKey` - Application Insights key for monitoring
- `logAnalyticsWorkspaceId` - Log Analytics workspace ID

## Cost Considerations

This template uses minimal-cost SKUs appropriate for development:
- ACR: Basic tier (~$5/month)
- App Service Plan: B1 (~$12/month)
- Application Insights: Pay-as-you-go
- Log Analytics: Per-GB ingestion

For production workloads, upgrade the SKUs in `main.parameters.json`.

## Security Notes

- App Service uses system-assigned managed identity for ACR authentication (no passwords)
- Admin user disabled on ACR
- HTTPS-only access enabled
- Network traffic restricted to Azure services

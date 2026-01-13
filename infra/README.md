# ZavaStorefront Azure Infrastructure

This folder contains the infrastructure-as-code (IaC) for deploying the ZavaStorefront web application to Azure using Bicep and Azure Developer CLI (AZD).

## Architecture Overview

The infrastructure provisions the following Azure resources:

- **Azure Container Registry (ACR)**: Stores Docker container images
- **Azure App Service (Linux)**: Hosts the web application as a Docker container
- **App Service Plan**: Linux-based hosting plan (B1 SKU for dev)
- **Application Insights**: Application monitoring and telemetry
- **Log Analytics Workspace**: Centralized logging
- **AI Hub (Microsoft Foundry)**: Machine learning workspace for GPT-4 and Phi models access
- **Storage Account**: Required for AI Hub
- **Key Vault**: Secure secrets management for AI Hub

## Security Features

- **Managed Identity**: The App Service uses a system-assigned managed identity
- **RBAC-based ACR Access**: No passwords - the App Service pulls images from ACR using the AcrPull role
- **HTTPS Only**: App Service enforces HTTPS
- **No Admin User**: ACR admin user is disabled
- **Secure Storage**: Storage account disables public blob access

## Prerequisites

Before deploying, ensure you have:

1. **Azure Subscription**: An active Azure subscription
2. **Azure CLI**: Installed and authenticated (`az login`)
3. **Azure Developer CLI**: Installed (`azd`)
4. **Docker**: Not required locally - builds happen in the cloud via ACR

## Deployment Instructions

### Step 1: Initialize AZD

```bash
azd init
```

Follow the prompts to configure your environment name and select your Azure subscription.

### Step 2: Preview Infrastructure

Preview the resources that will be created:

```bash
azd provision --preview
```

Review the output to ensure all resources are configured correctly.

### Step 3: Provision and Deploy

Deploy the infrastructure and application:

```bash
azd up
```

This command will:
1. Package the application source code
2. Provision all Azure resources using Bicep templates
3. Build the Docker image in ACR (no local Docker required)
4. Deploy the container to App Service

### Alternative: Provision Only

To provision infrastructure without deploying the application:

```bash
azd provision
```

### Step 4: Build and Push Docker Image

After provisioning, build and push the Docker image to ACR:

```bash
# Get ACR name from outputs
ACR_NAME=$(azd env get-values | grep AZURE_CONTAINER_REGISTRY_NAME | cut -d'=' -f2 | tr -d '"')

# Build image in ACR (no local Docker needed)
az acr build --registry $ACR_NAME --image zavastorefrontapp:latest --file Dockerfile .
```

### Step 5: Deploy Application

Deploy the application to App Service:

```bash
azd deploy
```

## File Structure

```
infra/
├── main.bicep                    # Root orchestration template
├── main.parameters.json          # Parameters file
├── modules/
│   ├── acr.bicep                # Azure Container Registry
│   ├── appService.bicep         # Web App for Containers
│   ├── appServicePlan.bicep     # App Service Plan (Linux)
│   ├── appInsights.bicep        # Application Insights
│   ├── logAnalytics.bicep       # Log Analytics Workspace
│   ├── roleAssignment.bicep     # RBAC role assignments
│   └── aiHub.bicep              # AI Hub (Microsoft Foundry)
└── README.md                     # This file
```

## Resource Naming Convention

Resources use a naming pattern: `{prefix}-{resource-type}-{unique-token}`

- **prefix**: `zavastore`
- **resource-type**: Type identifier (e.g., `acr`, `app`, `ai`)
- **unique-token**: Generated from subscription ID, environment name, and location

Example: `zavastoreacrabcd1234`

## Configuration Parameters

Key parameters in `main.bicep`:

- **environmentName**: Environment identifier (e.g., `dev`, `staging`, `prod`)
- **location**: Azure region (default: `westus3` for AI model availability)
- **dockerImageAndTag**: Docker image name and tag to deploy

## Environment Variables

After provisioning, AZD sets the following environment variables:

- `AZURE_CONTAINER_REGISTRY_NAME`: ACR name
- `AZURE_CONTAINER_REGISTRY_ENDPOINT`: ACR login server
- `SERVICE_WEB_ENDPOINTS`: App Service URL

View all environment variables:

```bash
azd env get-values
```

## Monitoring

### Application Insights

Access Application Insights in the Azure Portal to monitor:
- Application performance
- Request rates and response times
- Failed requests
- Exceptions
- Custom telemetry

### Log Analytics

Query logs using Kusto Query Language (KQL) in the Azure Portal.

## Cost Estimation

Approximate monthly costs for dev environment (westus3):

- App Service Plan (B1): ~$13/month
- Azure Container Registry (Basic): ~$5/month
- Application Insights: Pay-as-you-go (minimal for dev)
- Log Analytics: Pay-as-you-go (minimal for dev)
- AI Hub: Variable based on usage
- Storage Account: ~$1/month (minimal storage)
- Key Vault: ~$0.50/month

**Total estimated cost**: ~$20-30/month (excluding AI Hub compute usage)

## Cleanup

To delete all provisioned resources:

```bash
azd down
```

This will delete the entire resource group and all contained resources.

## Troubleshooting

### Provisioning Errors

If `azd up` or `azd provision` fails:

1. Check the error message carefully
2. Ensure you have sufficient permissions in the subscription
3. Verify region availability for all resources (especially AI Hub)
4. Check Azure subscription quotas

### Deployment Errors

If deployment fails after provisioning:

1. Verify the Docker image exists in ACR:
   ```bash
   az acr repository list --name $ACR_NAME
   ```

2. Check App Service logs:
   ```bash
   az webapp log tail --name <app-service-name> --resource-group <resource-group>
   ```

3. Verify managed identity has AcrPull role:
   ```bash
   az role assignment list --scope /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerRegistry/registries/{acr-name}
   ```

### AI Hub Issues

If AI Hub provisioning fails:

- Verify westus3 supports AI Hub resources
- Check Microsoft Foundry service availability in your region
- Ensure you have registered required resource providers:
  ```bash
  az provider register --namespace Microsoft.MachineLearningServices
  az provider register --namespace Microsoft.CognitiveServices
  ```

## Next Steps

After successful deployment:

1. **Build CI/CD Pipeline**: Create GitHub Actions workflow for automated deployments
2. **Configure Custom Domain**: Add a custom domain to App Service
3. **Enable Auto-scaling**: Configure auto-scaling rules for production
4. **Set Up Alerts**: Create Azure Monitor alerts for critical metrics
5. **Configure AI Models**: Set up GPT-4 and Phi models in AI Hub
6. **Implement App Configuration**: Use Azure App Configuration for settings management

## References

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [App Service Linux Containers](https://learn.microsoft.com/azure/app-service/configure-custom-container)
- [Azure Container Registry](https://learn.microsoft.com/azure/container-registry/)
- [Application Insights](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Microsoft Foundry (AI Hub)](https://learn.microsoft.com/azure/ai-foundry/)

# GitHub Actions Setup

This workflow builds your .NET app as a Docker container and deploys it to Azure App Service.

## Prerequisites

- Azure subscription with deployed infrastructure (app service and container registry)
- Repository with GitHub Actions enabled

## GitHub Secrets

Add these secrets to your repository (Settings > Secrets and variables > Actions > New repository secret):

- **`ACR_USERNAME`**: Azure Container Registry username
  - Get from Azure portal: Container Registry > Access keys > Username
  - Or run: `az acr credential show --name <registry-name> --query username -o tsv`

- **`ACR_PASSWORD`**: Azure Container Registry password
  - Get from Azure portal: Container Registry > Access keys > password
  - Or run: `az acr credential show --name <registry-name> --query passwords[0].value -o tsv`

- **`AZURE_PUBLISH_PROFILE`**: App Service publish profile
  - Download from Azure portal: App Service > Download publish profile
  - Or get using CLI: `az webapp deployment list-publishing-profiles --resource-group <rg-name> --name <app-name> --xml`

## GitHub Variables

Add these variables to your repository (Settings > Secrets and variables > Actions > New repository variable):

- **`ACR_LOGIN_SERVER`**: Azure Container Registry login server
  - Format: `<registry-name>.azurecr.io`
  - Get from Azure portal: Container Registry > Login server
  - Or run: `az acr show --name <registry-name> --query loginServer -o tsv`

- **`APP_SERVICE_NAME`**: Name of your Azure App Service
  - Get from Azure portal or Bicep outputs

## Workflow Trigger

The workflow automatically runs on:
- Push to `main` branch
- Manual trigger via Actions tab

Check the Actions tab in your repository to view workflow runs and logs.

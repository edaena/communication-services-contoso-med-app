#!/usr/bin/env bash

set -eou pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export $(grep -v '^#' $SCRIPT_DIR/../.env | xargs)

# Install prerequisites
echo "Adding Azure Communication Services extension..."
az extension add --name communication

# Test variables
if [ -z ${LOCATION+x} ]; then echo "Please set LOCATION in the .env file"; fi
if [ -z ${RESOURCE_PREFIX+x} ]; then echo "Please set RESOURCE_PREFIX in the .env file"; fi

# Resource Group
echo "Creating resource group..."
RESOURCE_GROUP_NAME=${RESOURCE_PREFIX}-contoso-med
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Azure Communcation Services
echo "Creating Communication Service..."
az communication create --name ${RESOURCE_PREFIX}-contoso-med-acs7 --location "Global" --data-location "United States" \
                        --resource-group $RESOURCE_GROUP_NAME

# Cosmos DB
echo "Creating Cosmos Instance..."
az cosmosdb create --name ${RESOURCE_PREFIX}-contoso-med-db --resource-group $RESOURCE_GROUP_NAME \
                  --enable-public-network --kind "MongoDB"
echo "Creating Cosmos Database..."
az cosmosdb mongodb database create --account-name ${RESOURCE_PREFIX}-contoso-med-db --resource-group $RESOURCE_GROUP_NAME \
                                    --name contoso-med

# Azure Logic App
# az logic workflow create --location $LOCATION  --resource_group $RESOURCE_GROUP_NAME

# App Service Plan
echo "Creating App Service Plan..."
APP_PLAN_NAME=${RESOURCE_PREFIX}-contoso-med-plan
az appservice plan create --name $APP_PLAN_NAME --resource-group $RESOURCE_GROUP_NAME --location $LOCATION \
                          --is-linux --sku P1V2

# Function App
echo "Creating Storage Account..."
az storage account create --name ${RESOURCE_PREFIX}contosomedapp --resource-group $RESOURCE_GROUP_NAME \
                          --kind StorageV2 
echo "Creating Function App..."
az functionapp create --resource-group $RESOURCE_GROUP_NAME --plan $APP_PLAN_NAME \
                      --name ${RESOURCE_PREFIX}-contoso-med-functions -s ${RESOURCE_PREFIX}contosomedapp \
                      --runtime node

# QnA Maker

# API App Service
echo "Creating App Service for API..."
az webapp create --name ${RESOURCE_PREFIX}-contoso-med-api --resource-group $RESOURCE_GROUP_NAME \
                 --plan $APP_PLAN_NAME --runtime "NODE|12-lts"

# Frontend Web App
echo "Configuring storage account for static site hosting..."
az storage blob service-properties update --account-name ${RESOURCE_PREFIX}contosomedapp --static-website \
                                          --index-document index.html

echo "Done!"
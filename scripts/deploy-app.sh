#!/usr/bin/env bash

set -eou pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export $(grep -v '^#' $SCRIPT_DIR/../.env | xargs)

# Test variables
if [ -z ${RESOURCE_PREFIX+x} ]; then echo "Please set RESOURCE_PREFIX in the .env file"; exit -1; fi

RESOURCE_GROUP_NAME=${RESOURCE_PREFIX}-contoso-med
SITE_STORAGE_NAME=${RESOURCE_PREFIX}contosomedapp

if [ "$(uname)" == "Darwin" ]; then
    EXPIRE=$(date -u -v +10M '+%Y-%m-%dT%H:%M:%SZ')
else
    EXPIRE=$(date -u -d "10 minutes" '+%Y-%m-%dT%H:%M:%SZ')
fi

echo "Getting account key..."
ACCOUNT_KEY=`az storage account keys list --account-name $SITE_STORAGE_NAME --resource-group $RESOURCE_GROUP_NAME \
                                          --query "[0].value" --output tsv`

echo "Generating SAS token..."
SAS=$(az storage container generate-sas --account-name $SITE_STORAGE_NAME --name '$web' --auth-mode key \
                                        --account-key $ACCOUNT_KEY --permissions acdlrw --expiry $EXPIRE)
SAS=`echo $SAS | sed 's/%3A/:/g;s/\"//g'`

# Deploy site
echo "Deploying site..."
azcopy cp "$SCRIPT_DIR/../contoso-web-app/build/*" "https://mikaelcontosomedapp.blob.core.windows.net/\$web?$SAS" --recursive=true

echo "Done!"
#!/usr/bin/env bash

set -eou pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export $(grep -v '^#' $SCRIPT_DIR/../.env | xargs)

if [ -z ${RESOURCE_PREFIX+x} ]; then echo "Please set RESOURCE_PREFIX in the .env file"; exit -1; fi

RESOURCE_GROUP_NAME=${RESOURCE_PREFIX}-contoso-med
FUNCTION_APP_NAME=${RESOURCE_PREFIX}-contoso-med-functions

echo "Zipping API code..."
cd "$SCRIPT_DIR/../contoso-az-functions/"
zip -r ../contoso-az-functions.zip * -x \*.zip
cd -

echo "Deploying API..."
az functionapp deployment source config-zip --resource-group $RESOURCE_GROUP_NAME \
                                       --name $FUNCTION_APP_NAME \
                                       --src "$SCRIPT_DIR/../contoso-az-functions.zip"

echo "Setting up Event subscription for function"
FUNCTION_APP_ID=`az functionapp show --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP_NAME \
                                     --query "id" --output tsv`
FUNCTION_ID="${FUNCTION_APP_ID}/functions/acs-chat-event-trigger"
ACS_ID=`az communication list --resource-group $RESOURCE_GROUP_NAME --query "[0].id" --output tsv`

az eventgrid event-subscription create --name "AcsChatHandlerSubscription" \
                                       --source-resource-id $ACS_ID \
                                       --endpoint-type azurefunction \
                                       --endpoint $FUNCTION_ID \
                                       --included-event-types "Microsoft.Communication.ChatMessageReceived"


echo "Done!"
#!/usr/bin/env bash

set -eou pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export $(grep -v '^#' $SCRIPT_DIR/../.env | xargs)

if [ -z ${RESOURCE_PREFIX+x} ]; then echo "Please set RESOURCE_PREFIX in the .env file"; exit -1; fi

RESOURCE_GROUP_NAME=${RESOURCE_PREFIX}-contoso-med
APP_SERVICE_NAME=${RESOURCE_PREFIX}-contoso-med-api

echo "Zipping API code..."
cd "$SCRIPT_DIR/../contoso-node-api/"
zip -r ../contoso-node-api.zip * -x node_modules/\* -x \*.zip
cd -

echo "Deploying API..."
az webapp deployment source config-zip --resource-group $RESOURCE_GROUP_NAME \
                                       --name $APP_SERVICE_NAME \
                                       --src "$SCRIPT_DIR/../contoso-node-api.zip"

echo "Done!"
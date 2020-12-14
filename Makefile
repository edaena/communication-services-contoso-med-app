define PROJECT_HELP_MSG
Usage:
	make help               show this message
	make deploy-infra       deploy the infrastructure for Contoso Med
	make deploy-app         deploy the frontend app for Contoso Med
	make deploy-api         deploy the api for Contoso Med
	make build-app          build the Contoso Med app
	make start-api          start the Contoso Med API
	make start-app          start the Contoso Med app
endef
export PROJECT_HELP_MSG

help:
	@echo "$$PROJECT_HELP_MSG" | less

deploy-infra:
	bash ./scripts/deploy-infra.sh

deploy-app:
	bash ./scripts/deploy-app.sh

deploy-api:
	bash ./scripts/deploy-api.sh

build-app:
	npm run-script build --prefix contoso-web-app

start-api:
	npm start --prefix contoso-node-api

start-app:
	npm start --prefix contoso-web-app
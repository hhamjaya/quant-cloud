SHELL := /bin/bash
INFRA_DIR := infra

.PHONY: build-lambda
build-lambda:
	cd $(INFRA_DIR) && ./build_lambda.sh

.PHONY: infra-init
infra-init:
	cd $(INFRA_DIR) && terraform init

.PHONY: deploy
deploy: build-lambda infra-init
	cd $(INFRA_DIR) && terraform apply -auto-approve
	@API=$$(cd $(INFRA_DIR) && terraform output -raw api_url); \
	  sed "s#_API_URL_#$$API#g" frontend/env.template.js > frontend/env.js; \
	  echo "env.js generated with API=$$API"
	  
.PHONY: fe-env
fe-env:
	@API=$$(cd $(INFRA_DIR) && terraform output -raw api_base_url); \
	echo "window.APP_CONFIG = { apiUrl: \"$$API\" };" > frontend/env.js; \
	echo "Wrote frontend/env.js with apiUrl=$$API"
 
.PHONY: fe-sync
fe-sync: fe-env
	@BUCKET=$$(cd $(INFRA_DIR) && terraform output -raw frontend_bucket); \
	echo "Syncing to s3://$$BUCKET"; \
	aws s3 sync frontend s3://$$BUCKET --delete
 
.PHONY: fe-open
fe-open:
	@URL=$$(cd $(INFRA_DIR) && terraform output -raw frontend_website_url); \
	echo $$URL

.PHONY: destroy
destroy:
	cd $(INFRA_DIR) && terraform destroy -auto-approve
	rm -f lambda.zip lambda.dist.zip frontend/env.js
include ../../common.mk
REGISTRY := $(AWS_ACCOUNT).dkr.ecr.ap-southeast-2.amazonaws.com
ECR_NAME:= $(REGISTRY)/$(subst ecr-,,$(STACK_NAME_GATEWAY_ECR))
REPOSITORY := $(REGISTRY)/$(NAME)
COMMIT_HASH := $(shell git log -1 --pretty=%h .)
DOCKER_LOGIN:=$(shell aws --profile chandana ecr get-login --no-include-email)

.PHONEY: push-image gateway-image gateway-ecr

push-image:	gateway-image gateway-ecr
	$(DOCKER_LOGIN)
	docker image push $(ECR_NAME):$(COMMIT_HASH) 
	docker image push $(ECR_NAME):latest

gateway-ecr:
	aws cloudformation deploy --template-file ../$(STACK_TEMPLATE_GATEWAY_ECR) \
	--stack-name $(STACK_NAME_GATEWAY_ECR) \
	--capabilities CAPABILITY_IAM --no-fail-on-empty-changeset
	
gateway-image:
	docker image build --rm --tag $(ECR_NAME):$(COMMIT_HASH) .
	docker image tag $(ECR_NAME):$(COMMIT_HASH) $(ECR_NAME):latest
	
	
# This Makefile deploys the infrastructure resources
include ../common.mk
REGISTRY := $(AWS_ACCOUNT).dkr.ecr.ap-southeast-2.amazonaws.com
ECR_NAME:= $(REGISTRY)/$(subst ecr-,,$(STACK_NAME_GATEWAY_ECR))
ECR_TAG := $(shell date +%Y%m%d%H%M)

REPOSITORY := $(REGISTRY)/$(NAME)
.PHONEY: deploy vpc ecs-cluster

deploy: vpc ecs-cluster

vpc:
	aws cloudformation deploy --template-file $(STACK_TEMPLATE_VPC) \
	--stack-name $(STACK_NAME_VPC) \
	--capabilities CAPABILITY_IAM --no-fail-on-empty-changeset

ecs-cluster:
	aws cloudformation deploy --template-file $(STACK_TEMPLATE_ECS_CLUSTER) \
	--stack-name $(STACK_NAME_ECS_CLUSTER) \
	--parameter-overrides VpcStack=$(STACK_NAME_VPC) \
	--capabilities CAPABILITY_IAM --no-fail-on-empty-changeset
	
gateway-ecr:
	aws cloudformation deploy --template-file $(STACK_TEMPLATE_GATEWAY_ECR) \
	--stack-name $(STACK_NAME_GATEWAY_ECR) \
	--capabilities CAPABILITY_IAM --no-fail-on-empty-changeset
	
gateway-image:
	docker image build --rm --tag $(ECR_NAME):$(ECR_TAG) --file docker/Dockerfile .
	docker image tag $(ECR_NAME):$(ECR_TAG) $(ECR_NAME):latest
	
push-image:	gateway-image gateway-ecr
	@$(shell aws ecr get-login --no-include-email > /dev/null)
	docker image push $(ECR_NAME):$(ECR_TAG) 
	docker image push $(ECR_NAME):latest
	
	

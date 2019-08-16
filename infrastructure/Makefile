# This Makefile deploys the infrastructure resources
include ../common.mk

.PHONEY: deploy vpc ecs-cluster

deploy: vpc ecs-cluster gateway

vpc:
	aws cloudformation deploy --template-file $(STACK_TEMPLATE_VPC) \
	--stack-name $(STACK_NAME_VPC) \
	--capabilities CAPABILITY_IAM --no-fail-on-empty-changeset

ecs-cluster:
	aws cloudformation deploy --template-file $(STACK_TEMPLATE_ECS_CLUSTER) \
	--stack-name $(STACK_NAME_ECS_CLUSTER) \
	--parameter-overrides VpcStack=$(STACK_NAME_VPC) \
	--capabilities CAPABILITY_IAM --no-fail-on-empty-changeset

gateway:	
	aws cloudformation deploy --template-file $(STACK_TEMPLATE_GATEWAY) \
	--stack-name $(STACK_NAME_GATEWAY) \
	--parameter-overrides VpcStack=$(STACK_NAME_VPC) \
	EcsClusterStack=$(STACK_NAME_ECS_CLUSTER) \
	--capabilities CAPABILITY_IAM --no-fail-on-empty-changeset
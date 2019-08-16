AWS_ACCOUNT:=$(shell aws iam list-roles --query 'Roles[?RoleName==`AWSServiceRoleForTrustedAdvisor`].[Arn]' --output text | cut -d \: -f 5)
# stack templates
STACK_TEMPLATE_VPC:=cfn/vpc.yml
STACK_TEMPLATE_GATEWAY_ECR:=cfn/ecr-gateway.yml
STACK_TEMPLATE_GATEWAY:=cfn/gateway.yml
STACK_TEMPLATE_ECS_CLUSTER:=cfn/ecs-cluster.yml

STACK_NAME_VPC := $(basename $(notdir $(STACK_TEMPLATE_VPC)))
STACK_NAME_GATEWAY_ECR := $(basename $(notdir $(STACK_TEMPLATE_GATEWAY_ECR)))
STACK_NAME_GATEWAY := $(basename $(notdir $(STACK_TEMPLATE_GATEWAY)))
STACK_NAME_ECS_CLUSTER := $(basename $(notdir $(STACK_TEMPLATE_ECS_CLUSTER)))
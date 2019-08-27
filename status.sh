#! /usr/bin/env bash

declare AWS=$(which aws); [ -x ${AWS} ] ||  { echo "cannot run aws, quitting"; exit 1; }
declare SED=$(which sed); [ -x ${SED} ] ||  { echo "cannot run sed, quitting"; exit 1; }
declare SLEEP=$(which sleep);[ -x ${SLEEP} ] ||  { echo "cannot run sleep, quitting"; exit 1; }

declare COMMAND=${0##*/}
declare ECS_STACK='ecs-cluster'
declare GATEWAY_STACK='gateway'
declare GATEWAY_SERVICE
declare ECS_CLUSTER_CAPACITY
declare GATEWAY_SERVICE_DESIRED
declare GATEWAY_SERVICE_RUNNING

function status()
{
	echo -n 'reading current capacity status '
	ECS_CLUSTER_CAPACITY=$( ${AWS} autoscaling describe-auto-scaling-groups \
	--auto-scaling-group-name ${_ECSGroup} \
	--query 'length(AutoScalingGroups[0].Instances[])')
	[ $? -eq 0 ] || { echo "failed to read cluster capacity"; exit 1; }
	
	while read desired running
	do
		GATEWAY_SERVICE_DESIRED=${desired}
		GATEWAY_SERVICE_RUNNING=${running}
	done < <(${AWS} --output text \
	ecs describe-services --cluster ${_ECSCluster} --services ${GATEWAY_SERVICE} \
	--query 'services[0].[desiredCount,runningCount]')
	[ $? -eq 0 ] || { echo "failed to read Gateway Capacity information"; exit 1; }
	echo " done"
}

function start()
{
	echo "starting ECS Cluster : ${_ECSCluster} with 1 instance"
	${AWS} autoscaling set-desired-capacity \
	--auto-scaling-group-name ${_ECSGroup} \
	--desired-capacity 1
	[ $? -eq 0 ] || { echo "failed to set capacity of AS Group ${_ECSGroup} to one"; exit 1; }
	
	echo "waiting one minute"
	${SLEEP} 60
	
	echo "starting Web Service ${WEB_SERVICE} with 1 server"
	${AWS} ecs update-service --cluster ${_ECSCluster} \
	--service ${WEB_SERVICE} --desired-count 1
	[ $? -eq 0 ] || { echo "failed to set capacity of Gateway Service ${WEB_SERVICE} to one"; exit 1; }
	
	echo "starting Gateway Service ${GATEWAY_SERVICE} with 1 server"
	${AWS} ecs update-service --cluster ${_ECSCluster} \
	--service ${GATEWAY_SERVICE} --desired-count 1
	[ $? -eq 0 ] || { echo "failed to set capacity of Gateway Service ${GATEWAY_SERVICE} to one"; exit 1; }
	
	status
}

function stop()
{
	echo "stopping Gateway Service ${GATEWAY_SERVICE} with 1 server"
	${AWS} ecs update-service --cluster ${_ECSCluster} \
	--service ${GATEWAY_SERVICE} --desired-count 0
	[ $? -eq 0 ] || { echo "failed to set capacity of Gateway Service ${GATEWAY_SERVICE} to zero"; exit 1; }
	
	echo "stopping Web Service ${WEB_SERVICE} with 1 server"
	${AWS} ecs update-service --cluster ${_ECSCluster} \
	--service ${WEB_SERVICE} --desired-count 0
	[ $? -eq 0 ] || { echo "failed to set capacity of Gateway Service ${WEB_SERVICE} to zero"; exit 1; }
	
	echo "waiting one minute"
	${SLEEP} 60
	
	echo "stopping ECS Cluster : ${_ECSCluster}"
	${AWS} autoscaling set-desired-capacity \
	--auto-scaling-group-name ${_ECSGroup} \
	--desired-capacity 0
	[ $? -eq 0 ] || { echo "failed to set capacity of AS Group ${_ECSGroup} to zero"; exit 1; }
	
	status
}
function status()
{
cat << EOT
ECS Cluster Name                  : ${_ECSCluster}
ECS Cluster Autocaling Group Name : ${_ECSGroup} 
                 Current Capacity : ${ECS_CLUSTER_CAPACITY} 
Gateway ECS Service Name          : ${GATEWAY_SERVICE}
        Capacity (Desired/Running): ${GATEWAY_SERVICE_DESIRED} /  ${GATEWAY_SERVICE_RUNNING}
EOT
}

# this will declare two variables, _ECSCluster and _ECSGroup
echo -n 'reading ECS Cluster Information : '
while read logical physical 
do
	declare -x _${logical}="${physical}"
done < <(${AWS} --output text \
cloudformation describe-stack-resources --stack-name ${ECS_STACK} \
--query 'StackResources[?LogicalResourceId==`ECSGroup`||LogicalResourceId==`ECSCluster`].[LogicalResourceId,PhysicalResourceId]')
[ $? -eq 0 ] || { echo "failed to read cluster information"; exit 1; }
echo " done"

# this will declare a variable named _GatewayService
echo -n 'reading Gateway stack details: '
while read logical physical 
do
	declare -x _${logical}="${physical}"
done < <(${AWS} --output text \
cloudformation describe-stack-resources --stack-name ${GATEWAY_STACK} \
--query 'StackResources[?LogicalResourceId==`GatewayService`].[LogicalResourceId,PhysicalResourceId]')
[ $? -eq 0 ] || { echo "failed to read Gateway information"; exit 1; }
GATEWAY_SERVICE=$( echo ${_GatewayService} | ${SED} -n 's/\(arn:.*service\/\)\(.*\)/\2/ p')
echo " done"

# this will declare a variable named _WebService
echo -n 'reading Gateway stack details: '
while read logical physical 
do
	declare -x _${logical}="${physical}"
done < <(${AWS} --output text \
cloudformation describe-stack-resources --stack-name ${GATEWAY_STACK} \
--query 'StackResources[?LogicalResourceId==`WebService`].[LogicalResourceId,PhysicalResourceId]')
[ $? -eq 0 ] || { echo "failed to read Gateway information"; exit 1; }
WEB_SERVICE=$( echo ${_WebService} | ${SED} -n 's/\(arn:.*service\/\)\(.*\)/\2/ p')
echo " done"

echo "Command : ${COMMAND}"
if [[ ${COMMAND} =~ [startstopstatus] ]]
then
	${COMMAND}
else
	echo 'invalid command, this script must be started as start, stop, or status.sh. Eg: AWS_PROFILE=<profile> ./status'
	exit 1 
fi
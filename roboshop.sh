#!bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0e357cdf3695bf2f9"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z0748101MT6SJ25GGSYP"
DOMAIN_Name="devsecopstrainee.site"

#for INSTANCES in ${INSTANCES[@]}  #it will take from the declared INSTANCES array
#for instance in ${INSTANCES[@]}
for instance in $@ #dynamically at the time of running the script we have to pass the arguments to install
do
    
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0e357cdf3695bf2f9 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=text}]" --query "Instances[0].InstanceId" \--output text)
    if [ $INSTANCES -ne frontend ]
    then
        IP=aws ec2 descripe-instances --instance-ids $INSTANCE_ID --query "Instances[0].PrivateIpAddress" \--output text
        echo "$INSTANCE_ID"
    else
        IP=aws ec2 descripe-instances --instance-ids $INSTANCE_ID --query "Instances[0].PublicIpAddress" \--output text
    fi

done
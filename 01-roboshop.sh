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
    #creating instance through cli
    echo "Script stated at $(date)"
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0e357cdf3695bf2f9 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $INSTANCES != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Instances[0].PrivateIpAddress" --output text)
        
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Instances[0].PublicIpAddress" --output text)
    fi
    echo "$INSTANCE_ID ip address is $IP"
done


#In the above logic we are creating instance at line 14 with diffrent names mentioned at line 5
#if it is not front end as we mentioned condition at line 15, we will take its private ip and we will print at line 22
#if its a frontend instance we will take its public ip and we will print.
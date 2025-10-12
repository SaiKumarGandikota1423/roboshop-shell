#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-0e6e277cb9db6a9b2
INSTANCES=("mongodb" "Redis" "mysql" "rabbitmq" "catalouge" "user" "cart" "shipping" "payment" "dispatch" "web" )

for i in "${INSTANCES[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "mongmysql" ] || [ $i == "shipping" ]
    then 
        INSTANCES_TYPE="t3.small"
    else
        INSTANCES_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --instance-type $INSTANCES_TYPE --security-group-ids sg-0e6e277cb9db6a9b2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"
done


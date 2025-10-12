#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-0e6e277cb9db6a9b2
INSTANCES=("mongodb" "Redis" "mysql" "rabbitmq" "catalouge" "user" "cart" "shipping" "payment" "dispatch" "web" )
ZONE_ID=Z03390721TAW3412ZTWXG
DOMAIN_NAME=devopsawscloud.shop

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

    # Creates route 53 records based on env name
    # Create R53 records make sure you need to delete existing records
    #aws route53 change-resource-record-sets \
    #--hosted-zone-id $ZONE_ID \
    #--change-batch "
    #{
     #   "Comment": "Testing creating a record set"
      #  ,"Changes": [{
      #  "Action"              : "CREATE"
       ##    "Name"              : "$i.$DOMAIN_NAME"
         #   ,"Type"             : "A"
          #  ,"TTL"              : 1
           # ,"ResourceRecords"  : [{
            #    "Value"         : "$IP_ADDRESS"
            #}]
        #}
        #}]
    #}
    #"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
        {
            "Comment": "Creating a record set for cognito endpoint"
            ,"Changes": [{
            "Action"              : "CREATE"
            ,"ResourceRecordSet"  : {
                "Name"              : "'$i'.'$DOMAIN_NAME'"
                ,"Type"             : "A"
                ,"TTL"              : 1
                ,"ResourceRecords"  : [{
                    "Value"         : "'$IP_ADDRESS'"
                }]
            }
            }]
        }
            ' 

done


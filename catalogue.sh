#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb04062025.devopsawscloud.shop

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR::Please run this script with root user access $N"
    exit 1 # you can give other than 0
else   
    echo -e "You are the root user"
fi #fi means reverse of if,indicatiing the condition end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabaling NodeJS:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NOdeJS:18"

id roboshop #if roboshop user does not exist, then it is failed
if [ $? -ne 0 ] 
then 
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else 
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "Creating App Directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE "Downloading catalogue Application"

cd /app 
 
unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping catalogue"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

#use absolute path, because catalogu.service exisgts there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service  &>> $LOGFILE

VALIDATE $? "Copying catalogue.service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $ "Enable Catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting Catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongo.repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB Client"

mongo --host $MONGDB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading Catalogue data into MongoDB"
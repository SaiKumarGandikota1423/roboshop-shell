#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb04062025.devopsawscloud.shop

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

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
    echo -e "$R ERROR:: Please run script with root user access"
    exit 1 # you can give other than 0
else
    echo -e "You Are The ROOT User"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling the current nodeJS"

dnf module enable nodejs:18 -y  &>> $LOGFILE

VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y  &>> $LOGFILE

VALIDATE $? "Installing NodeJS:18"

id roboshop # if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else 
    echo -e "roboshop user already exists $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading User Application"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user   &>> $LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mango.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mangodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB Client"

mongo --host $MONGDB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into MongoDB"
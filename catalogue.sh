#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
RED="\e[31m"  # Red color code
GREEN="\e[32m" # Green color code
YELLOW="\e[33m" # Yelloe color
NORMAL="\e[0m" # Normal code

echo "This script has started at $TIMESTAMP" &>> $LOG_FILE

#validating after the excecution of every statement
VALIDATE(){
    if [ $1 -ne 0 ] 
    then
        echo -e "Error:: $2 $RED Failed $NORMAL"
        exit 1
    else
        echo -e "$2 $GREEN Success $NORMAL"
    fi
}

#checking for the root user
if [ $ID -ne 0 ] 
then
    echo "You are not a root user"
    exit 1 #if exit=0, cmd will continue, if exit>0, cmd will exit
else    
    echo "You are a root user"
fi


dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling old module"

dnf module enable nodejs:18 -y &>> $LOG_FILE
VALIDATE $? "Enabling Nodejs v18"

dnf module disable nodejs - &>> $LOG_FILE
VALIDATE $? "Installing Nodejs"

id roboshop
if [$? -ne 0] 
then
    useradd roboshop 
else
    echo "roboshop user already exist: $YELLOW skipping $NORMAL"
fi

VALIDATE $? "Verifying user is created"


mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Verifying if the dir is created"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOG_FILE
VALIDATE $? "Downloading the Catalogue application"

cd /app 
unzip /tmp/catalogue.zip &>> $LOG_FILE
VALIDATE $? "Unzipping the file"

npm install &>> $LOG_FILE
VALIDATE $? "NPM installing"

#create a catalogue service
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copying the catalogue service file"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue &>> $LOG_FILE
VALIDATE $? "Enable catalogue"

systemctl start catalogue &>> $LOG_FILE
VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOG_FILE
VALIDATE $? "Installing MongoDB client"

mongo --host 172.31.86.37 </app/schema/catalogue.js &>> $LOG_FILE
VALIDATE $? "Loading catalouge data into MongoDB"
#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
RED="\e[31m"  # Red color code
GREEN="\e[32m" # Green color code
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

#create a mongo.repo
#now copy the repo to a file
cp mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
VALIDATE $? "Copying the MongoDB repo"


dnf install mongodb-org -y  &>> $LOG_FILE
VALIDATE $? "Inatallation of MongoDB is"

dnf enable mongod &>> $LOG_FILE
VALIDATE $? "Enabling MangoDB is"

dnf start mongod &>> $LOG_FILE
VALIDATE $? "Starting MongoDB is"

#to edit a file in run time, we use sed editor
#s for substitute, -i for permanant, 127.o.o.1 to 0.0.0.0
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
VALIDATE $? "Remote access to Internet is"

systemctl restart mongod &>> $LOG_FILE
VALIDATE $? "MongoDB service restart is"
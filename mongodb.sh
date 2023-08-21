#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="'\e[33m"

if [ $USERID -ne 0 ]
then 
    echo -e "$R ERROR: please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2...$R Failure $N"
        exit 1
    else
        echo -e "$2....$G success $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MongoDB repo into yum.repos.d"

yum install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installation of mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Edited mongodb conf"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "restarting mongodb"
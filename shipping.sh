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

yum install maven -y &>>$LOGFILE

VALIDATE $? "installing maven"

useradd roboshop &>>$LOGFILE 

VALIDATE $? ""

mkdir /app &>>$LOGFILE 

VALIDATE $? ""

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE

VALIDATE $? "downloading shipping artifact"

cd /app &>>$LOGFILE

VALIDATE $? ""

unzip /tmp/shipping.zip &>>$LOGFILE

VALIDATE $? "unzipping shiping"

cd /app &>>$LOGFILE

VALIDATE $? "moving to app directory"

mvn clean package &>>$LOGFILE 

VALIDATE $? "packaging shipping app"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE

VALIDATE $? "renaming shipping jar"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE

VALIDATE $? "copying shipping jar"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon -reload"

systemctl enable shipping &>>$LOGFILE

VALIDATE $? "enabling shiiping "

systemctl start shipping &>>$LOGFILE

VALIDATE $? "starting shiiping "

yum install mysql -y &>>$LOGFILE

VALIDATE $? "installing mysql client"

mysql -h mysql.krishnadevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE

VALIDATE $? "loaded countries and cities"

systemctl restart shipping &>>$LOGFILE

VALIDATE $? "restarting shiping"
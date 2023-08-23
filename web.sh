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

yum install nginx -y &>>$LOGFILE

VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOGFILE

VALIDATE $? "enabling nginx"

systemctl start nginx &>>$LOGFILE

VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE

VALIDATE $? "removing default index html files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE 

VALIDATE $? "downloading web artifact"

cd /usr/share/nginx/html &>>$LOGFILE 

VALIDATE $? "moving to default html"

unzip /tmp/web.zip &>>$LOGFILE 

VALIDATE $? "unzipping web artifact"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf  &>>$LOGFILE 

VALIDATE $? "copying roboshop config"

systemctl restart nginx &>>$LOGFILE

VALIDATE $? "restarting nginx"
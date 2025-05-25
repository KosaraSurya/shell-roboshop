#!bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FOLDER="/var/log/shellpractice"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0e357cdf3695bf2f9"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z0748101MT6SJ25GGSYP"
DOMAIN_Name="devsecopstrainee.site"
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER    #-p will check whether dir is there or not, if it not exits it will create the folder.
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR : Please process with root access $N"
    exit 1
else
    echo -e "$G access granted please proceed $N"
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R ERROR : $2 was failed $N"
        exit 1
    else
        echo -e "$G $2 was successful $N"
    fi
}

dnf module disable nodejs
VALIDATE $? "Disabling default version of nodejs"

dnf enable module nodejs:20 -y
VALIDATE $? "ebaling 20version of nodejs"

dnf install nodejs -y
VALIDATE $? "Downloading nodejs"

id roboshop

if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else 
    echo -e "$Y user already created $N"
fi

mkdir -p /app

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
VALIDATE $? "Downloading catalogue"

rm -rf /app/*
cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "Un-Zipping catalogue"

cd /app 
npm install
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying the service"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "catalogue started"

cp mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y
VALIDATE $? "installing mongodb client"

STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -ne 0]
then
    mongosh --host mongodb.devsecopstrainee.site </app/db/master-data.js
else 
    echo -e "$G master data was already loaded $N"

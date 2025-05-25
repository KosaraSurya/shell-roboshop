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
    echo -e "$G Root access granted please proceed $N"
fi

echo -e "please enter the user"
read -s MYSQL_ROOT_PASSWORD

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

dnf install maven -y

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else 
    echo -e "$Y user is already created $N"
fi

mkdir -p /app

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip
rm -rf /app/*
cd /app 
unzip /tmp/shipping.zip

mvn clean package
VALIDATE $? "Packaging the shipping application"

mv target/shipping-1.0.jar shipping.jar

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "downloading the shipping application"

systemctl daemon-reload
VALIDATE $? "Daemon Realod"

systemctl enable shipping
VALIDATE $? "enabling Shipping"
systemctl start shipping
VALIDATE $? "Starting Shipping"


dnf install mysql -y

mysql -h mysql.devsecopstrainee.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pMYSQL_ROOT_PASSWORD < /app/db/schema.sql
    mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pMYSQL_ROOT_PASSWORD < /app/db/app-user.sql
    mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pMYSQL_ROOT_PASSWORD < /app/db/master-data.sql
    VALIDATE $? "Loading data into MySQL"
    
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi
systemctl restart shipping
VALIDATE $? "Restart shipping"

#!bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FOLDER="/var/log/shellpractice"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE

id roboshop &>>$LOG_FILE

if [ $? -ne 0]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else 
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir -p /app

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
VALIDATE $? "downloading payment"

rm -rf /app/*
cd /app 
unzip /tmp/payment.zip
VALIDATE $? "unzipping payment"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Copying payment service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon Reload"

systemctl enable payment 
systemctl start payment &>>$LOG_FILE
VALIDATE $? "Starting payment"
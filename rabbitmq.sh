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

echo "Please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWD

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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server
VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server
VALIDATE $? "starting rabbitmq"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWD &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"


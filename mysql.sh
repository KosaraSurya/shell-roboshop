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

mkdir -p $LOG_FOLDER    #-p will check whether dir is there or not, if it not exits it will create the folder.
START_TIME=$(date +%s)
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR : Please process with root access $N"
    exit 1
else
    echo -e "$G access granted please proceed $N"
fi

echo  "Please enter root password to setup"
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

dnf install mysql-server -y &>>LOG_FILE
VALIDATE $? "installing mysql server"

systemctl enable mysqld
VALIDATE $? "enabling mysql"

systemctl start mysqld
VALIDATE $? "stating mysql" 

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>LOG_FILE
VALIDATE $? "setting mysql password"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
#!/bin/bash
set -ex
apt update
apt install wget
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --update

sleep 5
apt update
apt install -y postgresql-client

bash -x ./env.sh
backup_filename="pgbackup_"$(date +"%d.%m.%y-%H-%M-%S")
echo -e "\nBacking Up ..."
pg_dumpall -h ${PG_HOST} -p ${PG_PORT} -U ${PG_ADMIN_USER} -f ${backup_filename}
if [[ $? != 0 ]]
then
    echo "Exiting......"
    exit
fi
sleep 10
echo -e "\nFinished Backup"
tar -czf ${backup_filename}".tar.gz" ${backup_filename}

aws s3 cp ./${backup_filename}".tar.gz" ${BUCKET_NAME}
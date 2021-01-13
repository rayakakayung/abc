#!/bin/bash

counter=0

vanished=1

log_file="/var/log/backup.log.`date +%a`"

backup_dir="/home /var /etc /usr"

#echo "`date +%d%m%y" "%H:%M:%S` start daily backup" > $log_file

function TIME(){
DATE=`date +%d%m%y" "%H:%M:%S`
echo $DATE
}

while [ $vanished -eq 1 ]; do {

echo "$(TIME) Start daily backup" > $log_file

rsync --ignore-errors -va --delete  $backup_dir /backup/daily/ >> $log_file 2>&1 || echo -e "\n$(TIME) BACKUP FAILED!!!!\n" >> $log_file

echo "$(TIME) End daily backup" >> $log_file

grep "vanished" $log_file

if [[ ($? -eq 0) && ($counter -lt 10) ]]; then

        vanished=1
        let counter=counter+1
        echo -e "\nRetried $counter times\n" >> $log_file
else
        vanished=0
        echo -e "\nRetried $counter times\n" >> $log_file
fi

} done

grep "BACKUP FAILED" $log_file

if [ $? -eq 0 ]; then

        echo -e "Backup Failed, check $log_file for detailed information\n\n`head -n1 $log_file;tail -n10 $log_file`" | mail -s"Backup FAILED `hostname` Daily `date +%a`" support@abchk.com
else

        echo -e "Backup Completed, check $log_file for detailed information\n\n`head -n1 $log_file;tail -n10 $log_file`" | mail -s"Backup COMPLETED `hostname` Daily `date +%a`" support@abchk.com
fi


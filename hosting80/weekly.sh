#!/bin/bash

POOL=Hosting-80

counter=0

vanished=1

log_file="/var/log/backup.log.`date +%a`_weekly"

backup_dir="/home /var /etc /usr /lib"

backup_location="/backup_on_storage"


function TIME(){
DATE=`date +%d%m%y" "%H:%M:%S`
echo $DATE
}

umount -f $backup_location

echo "$(TIME) Start Weekly backup" > $log_file

mount -t nfs -o tcp storage.abchk.net:/ZFSPOOL/$POOL $backup_location

if [ $? -eq 0 ]; then  {

while [ $vanished -eq 1 ]; do {

echo "$(TIME) Start Weekly backup" > $log_file

rsync -avpogtStlHz --exclude="/var/spool/exim" --ignore-errors -va --delete  $backup_dir $backup_location >> $log_file 2>&1 || echo -e "\n$(TIME) BACKUP FAILED!!!!\n" >> $log_file

echo "$(TIME) End Weekly backup" >> $log_file

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

        echo -e "Backup Failed, check $log_file for detailed information\n\n`head -n1 $log_file;tail -n10 $log_file`" | mail -s"Backup FAILED `hostname` Weekly `date +%a`" support@abchk.com
else

        echo -e "Backup Completed, check $log_file for detailed information\n\n`head -n1 $log_file;tail -n10 $log_file`" | mail -s"Backup COMPLETED `hostname` Weekly `date +%a`" support@abchk.com

rm -rf $backup_location/last_backup*

touch $backup_location/last_backup_`date +%d%m%Y_%H:%M:%S`

umount $backup_location

fi
}

else

echo -e "$(TIME) BACKUP FAILED!!!!: Cannot mount remote partition"  > $log_file

echo "$(TIME) End Weekly backup" >> $log_file
mail -s"Backup FAILED `hostname` Weekly `date +%a`" support@abchk.com < $log_file

fi


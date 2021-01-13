#!/bin/bash

declare -i no_of_backup day_keep

save_path='/backup/mysql_backup'
backup_log='/var/log/mysql_backup.log'
day_keep='7'
today=`date +%F`
time=`date +%T`

msg1="$today folder is already exist!!"
msg2="$save_path folder do not exis!!"

#### Create and check folder

if [ ! -d "$save_path" ]; then
 echo "$msg2"
 echo "$today $time $msg2" >> $backup_log
 exit
fi

if [ -d "$save_path/$today" ]; then
 echo "$today folder is already exist!!"
 echo "$today $time $msg1" >> $backup_log
 exit
fi

mkdir $save_path/$today
mkdir $save_path/$today/dump

##### Backup method 1 copy database (tar.gz) ######

#tar -zcf mysql_backup_copy_$today.tar.gz /var/lib/mysql
#mv mysql_backup_copy_$today.tar.gz $save_path/$today
#echo "$today $time zip /var/lib/mysql to $save_path/$today/mysql_backup_copy_$today.tar.gz success" >> $backup_log

##### Backup method 2 dump database (mysqldump) ######

total=`ls -1 /var/lib/mysql |wc -l |tr -d ' '`

echo "######### dumping database log ($today $time) #########" >> $backup_log

for (( i = 1; i <= "$total"; i++ ))
{
database=`ls -1 /var/lib/mysql |head -$i |tail -1`
if [ -d "/var/lib/mysql/$database" ]; then
 mysqldump -u da_admin -p`awk -F "=" '/password/ {print $2}'   /usr/local/directadmin/conf/my.cnf` $database > $save_path/$today/dump/"$database"_"$today".sql
 echo "Dumping $database to $save_path/$today/dump/\"$database\"_\"$today\".sql"
 echo "$today $time mysqldump $database to $save_path/$today/dump/$database'_'$today.sql success" >> $backup_log
fi
}
echo "######### End of dumping database log #########" >> $backup_log


#### check and delete over one week backup ####
no_of_backup=`ls -1 $save_path |wc -l |tr -d ' '`
day_keep=$day_keep+1
if [ $no_of_backup -ge $day_keep ]; then
 delete_backup=`ls -1 $save_path |head -1`
 rm -rf "$save_path/$delete_backup"
 echo "$today $time Delete $save_path/$delete_backup backup success" >> $backup_log
fi


#!/bin/sh
##******************ONLY IF YOU HAVE CONVERTED YOUR TABLE TO InnoDB**********************

# call this script from within screen to get binaries, processes releases and 
# every half day get tv/theatre info and optimise the database
# every 2 hours run cleanup scripts

set -e

export NEWZNAB_PATH='/var/www/newznab/misc/update_scripts'
export INNODB_PATH='/var/www/newznab/misc/testing/innodb'
export TESTING='/var/www/newznab/misc/testing'
export NEWZNAB_SLEEP_TIME='10' # in seconds
export NZBS='/path/to/nzbs'  #path to your nzb files
export MyUSER='root' #mysql user
export MyPASS='password' #mysql password
export DATABASE='newznab'
export MAXDAYS='180'  #max days for backfill
export MAXRET='2'  #max days for backfill
export MYSQL="$(which mysql)"
export PHP="$(which php5)"
export MYSQL_CMD1="UPDATE groups set backfill_target=backfill_target+1 where active=1 and backfill_target<$MAXDAYS;"
export MYSQL_CMD2="UPDATE site set value=$MAXRET where setting='rawretentiondays';"
export MYSQL_CMD3="UPDATE site set value=0 where setting='rawretentiondays';"
export MYSQL_CMD4="SELECT * from groups where active=1;"

LASTOPTIMIZE1=`date +%s`
LASTOPTIMIZE2=`date +%s`
COUNTER=0
LOOP=1

#check for files
[ ! -f $NEWZNAB_PATH/update_releases.php ] && echo $NEWZNAB_PATH/update_releases.php not found && exit
[ ! -f $INNODB_PATH/update_binaries.php ] && echo $INNODB_PATH/update_binaries.php not found && exit
[ ! -f $INNODB_PATH/nzb-import.php ] && echo $INNODB_PATH/nzb-import.php not found && exit
[ ! -f $INNODB_PATH/backfill.php ] && echo $INNODB_PATH/backfill.php not found && exit
[ ! -f $NEWZNAB_PATH/update_predb.php ] && echo $NEWZNAB_PATH/update_predb.php not found && exit
[ ! -f $NEWZNAB_PATH/removespecial.php ] && echo $NEWZNAB_PATH/removespecial.php not found && exit
[ ! -f $NEWZNAB_PATH/update_cleanup.php ] && echo $NEWZNAB_PATH/update_cleanup.php not found && exit
[ ! -f $NEWZNAB_PATH/update_parsing.php ] && echo $NEWZNAB_PATH/update_parsing.php not found && exit
[ ! -f $NEWZNAB_PATH/optimise_db.php ] && echo $NEWZNAB_PATH/optimise_db.php not found && exit
[ ! -f $NEWZNAB_PATH/update_tvschedule.php ] && echo $NEWZNAB_PATH/update_tvschedule.php not found && exit
[ ! -f $NEWZNAB_PATH/update_theaters.php ] && echo $NEWZNAB_PATH/update_theaters.php not found && exit
[ ! -f $TESTING/getConsole.php ] && echo $TESTING/getConsole.php not found && exit
[ ! -f $TESTING/getCovers.php ] && echo $TESTING/getCovers.php not found && exit

while :

 do
CURRTIME=`date +%s`

#update regex's and clear any unfinished work from previous runs, runs once
while [ $COUNTER -lt 1 ]
do
	/usr/bin/clear
	echo "update regex's and clear any unfinished work from previous runs"
	printf "\033]0; Loop $LOOP - update regex's and clear any unfinished work from previous runs\007\003\n"
	cd $NEWZNAB_PATH
	[ -f $NEWZNAB_PATH/update_releases.php ] && $PHP $NEWZNAB_PATH/update_releases.php
	COUNTER=$(( $COUNTER + 1 ))
done

#set retention days
$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD2"

#make active groups current
cd $INNODB_PATH
GROUPCOUNT=`$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD4"`
printf "\033]0; Loop $LOOP - Running $INNODB_PATH/update_binaries.php on $GROUPCOUNT groups\007\003\n"
[ -f $INNODB_PATH/update_binaries.php ] && $PHP $INNODB_PATH/update_binaries.php
cd $NEWZNAB_PATH
printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_releases.php\007\003\n"
[ -f $NEWZNAB_PATH/update_releases.php ] && $PHP $NEWZNAB_PATH/update_releases.php

#set retention days to 0
$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD3"

#import nzb's
cd $INNODB_PATH
NZBCOUNT=`ls -1 ${NZBS} | wc -l`
printf "\033]0; Loop $LOOP - Running $INNODB_PATH/nzb-import.php ${NZBS} true - $NZBCOUNT nzb's remaining\007\003\n"
[ -f $INNODB_PATH/nzb-import.php ] && $PHP $INNODB_PATH/nzb-import.php ${NZBS} true
cd $NEWZNAB_PATH
printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_releases.php\007\003\n"
[ -f $NEWZNAB_PATH/update_releases.php ] && $PHP $NEWZNAB_PATH/update_releases.php

#get backfill for all active groups
cd $INNODB_PATH
GROUPCOUNT=`$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD4"`
printf "\033]0; Loop $LOOP - Running $PHP $INNODB_PATH/backfill.php on $GROUPCOUNT groups\007\003\n"
[ -f $INNODB_PATH/backfill.php ] && $PHP $INNODB_PATH/backfill.php
cd $NEWZNAB_PATH
printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_releases.php\007\003\n"
[ -f $NEWZNAB_PATH/update_releases.php ] && $PHP $NEWZNAB_PATH/update_releases.php

#reset retention days
$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD2"

DIFF=$(($CURRTIME-$LASTOPTIMIZE1))
if [ "$DIFF" -gt 3600 ] || [ "$DIFF" -lt 1 ]
then
	LASTOPTIMIZE1=`date +%s`
	#run some cleanup scripts
	printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_predb.php true\007\003\n"
	[ -f $NEWZNAB_PATH/update_predb.php ] && $PHP $NEWZNAB_PATH/update_predb.php true
	printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/removespecial.php\007\003\n"
	[ -f $NEWZNAB_PATH/removespecial.php ] && $PHP $NEWZNAB_PATH/removespecial.php
	printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_cleanup.php\007\003\n"
	[ -f $NEWZNAB_PATH/update_cleanup.php ] && $PHP $NEWZNAB_PATH/update_cleanup.php
	printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_parsing.php\007\003\n"
	[ -f $NEWZNAB_PATH/update_parsing.php ] && $PHP $NEWZNAB_PATH/update_parsing.php
	printf "\033]0; Loop $LOOP - Running $TESTING/getConsole.php\007\003\n"
	[ -f $TESTING/getConsole.php ] && $PHP $TESTING/getConsole.php
	printf "\033]0; Loop $LOOP - Running $TESTING/getCovers.php\007\003\n"
	[ -f $TESTING/getCovers.php ] && $PHP $TESTING/getCovers.php
fi

#increment backfill days
$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "${MYSQL_CMD1}"


DIFF=$(($CURRTIME-$LASTOPTIMIZE2))
if [ "$DIFF" -gt 43200 ] || [ "$DIFF" -lt 1 ]
then
	LASTOPTIMIZE2=`date +%s`
	printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/optimise_db.php\007\003\n"
	[ -f $NEWZNAB_PATH/optimise_db.php ] && $PHP $NEWZNAB_PATH/optimise_db.php
	printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_tvschedule.php\007\003\n"
	[ -f $NEWZNAB_PATH/update_tvschedule.php ] && $PHP $NEWZNAB_PATH/update_tvschedule.php
	printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_theaters.php\007\003\n"
	[ -f $NEWZNAB_PATH/update_theaters.php ] && $PHP $NEWZNAB_PATH/update_theaters.php
fi

printf "\033]0; End of Loop $LOOP\007\003\n"
LOOP=$(( $LOOP + 1 ))
echo "waiting $NEWZNAB_SLEEP_TIME seconds..."
sleep $NEWZNAB_SLEEP_TIME

done


#!/bin/sh
##******************ONLY IF YOU HAVE CONVERTED YOUR TABLE TO InnoDB**********************

# call this script from within screen to get binaries, processes releases and 
# every half day get tv/theatre info and optimise the database
# every 2 hours run cleanup scripts

# These scripts are constantly changing (still learning). If something doesn't work as expected /msg jonnyboy on irc.
# Tell me what is broken and I'll check and fix if necessary.
# I have include my innodb my.cnf, if you see something that is out of whack or may be better configured, please msg me.

# If you don't need something to run, just comment it out. The lines that start '[ ! -f' are the ones to comment, ie. '#[ ! -f'


set -e

export NEWZNAB_PATH='/var/www/newznab/misc/update_scripts'
export NEWZNAB_ADMIN_PATH='/var/www/newznab/www/admin'
export TESTING='/var/www/newznab/misc/testing'
export NEWZNAB_SLEEP_TIME='10' # in seconds
export NZBS='/path/to/nzbs'  #path to your nzb files to be imported
export MyUSER='root' #mysql user
export MyPASS='password' #mysql password
export DATABASE='newznab'
export MAXDAYS='180'  #max days for backfill
export MAXRET='2'  #max days for backfill
export MYSQL="$(which mysql)"
export PHP="$(which php5)"
export MYSQL_CMD1="UPDATE groups set backfill_target=backfill_target+1 where active=1 and backfill_target<$MAXDAYS;"
export MYSQL_CMD4="SELECT * from groups where active=1;"

LASTOPTIMIZE1=`date +%s`
LASTOPTIMIZE2=`date +%s`
COUNTER=0
LOOP=1

#check for files
[ ! -f $NEWZNAB_PATH/update_releases.php ] && echo $NEWZNAB_PATH/update_releases.php not found && exit
[ ! -f $NEWZNAB_PATH/update_binaries_threaded.php ] && echo $NEWZNAB_PATH/update_binaries_threaded.php not found && exit
[ ! -f $NEWZNAB_ADMIN_PATH/nzb-importmodified.php ] && echo $NEWZNAB_ADMIN_PATH/nzb-importmodified.php not found && exit
[ ! -f $NEWZNAB_PATH/backfill_threaded.php ] && echo $NEWZNAB_PATH/backfill_threaded.php not found && exit
[ ! -f $NEWZNAB_PATH/update_predb.php ] && echo $NEWZNAB_PATH/update_predb.php not found && exit
[ ! -f $TESTING/removespecial.php ] && echo $TESTING/removespecial.php not found && exit
[ ! -f $TESTING/update_cleanup.php ] && echo $TESTING/update_cleanup.php not found && exit
[ ! -f $TESTING/update_parsing.php ] && echo $TESTING/update_parsing.php not found && exit
[ ! -f $NEWZNAB_PATH/optimise_db.php ] && echo $NEWZNAB_PATH/optimise_db.php not found && exit
[ ! -f $NEWZNAB_PATH/update_tvschedule.php ] && echo $NEWZNAB_PATH/update_tvschedule.php not found && exit
[ ! -f $NEWZNAB_PATH/update_theaters.php ] && echo $NEWZNAB_PATH/update_theaters.php not found && exit

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

#make active groups current
GROUPCOUNT=`$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD4"`
printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_binaries_threaded.php on $GROUPCOUNT groups\007\003\n"
cd $NEWZNAB_PATH
[ -f $NEWZNAB_PATH/update_binaries_threaded.php ] && $PHP $NEWZNAB_PATH/update_binaries_threaded.php
printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_releases.php\007\003\n"
[ -f $NEWZNAB_PATH/update_releases.php ] && $PHP $NEWZNAB_PATH/update_releases.php

#import nzb's
NZBCOUNT=`ls -1 ${NZBS} | wc -l`
printf "\033]0; Loop $LOOP - Running NEWZNAB_ADMIN_PATH/nzb-importmodified.php ${NZBS} true - $NZBCOUNT nzb's remaining\007\003\n"
cd $NEWZNAB_ADMIN_PATH
[ -f $NEWZNAB_ADMIN_PATH/nzb-importmodified.php ] && $PHP $NEWZNAB_ADMIN_PATH/nzb-importmodified.php ${NZBS} true
printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_releases.php\007\003\n"
cd $NEWZNAB_PATH
[ -f $NEWZNAB_PATH/update_releases.php ] && $PHP $NEWZNAB_PATH/update_releases.php

#get backfill for all active groups
GROUPCOUNT=`$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD4"`
printf "\033]0; Loop $LOOP - Running $PHP $NEWZNAB_PATH/backfill_threaded.php on $GROUPCOUNT groups\007\003\n"
[ -f $NEWZNAB_PATH/backfill_threaded.php ] && $PHP $NEWZNAB_PATH/backfill_threaded.php
printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_releases.php\007\003\n"
[ -f $NEWZNAB_PATH/update_releases.php ] && $PHP $NEWZNAB_PATH/update_releases.php

DIFF=$(($CURRTIME-$LASTOPTIMIZE1))
if [ "$DIFF" -gt 3600 ] || [ "$DIFF" -lt 1 ]
then
	LASTOPTIMIZE1=`date +%s`
	#run some cleanup scripts
	printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/update_predb.php true\007\003\n"
	cd $NEWZNAB_PATH
	[ -f $NEWZNAB_PATH/update_predb.php ] && $PHP $NEWZNAB_PATH/update_predb.php true
	cd $TESTING
	printf "\033]0; Loop $LOOP - Running $TESTING/removespecial.php\007\003\n"
	[ -f $TESTING/removespecial.php ] && $PHP $TESTING/removespecial.php
	printf "\033]0; Loop $LOOP - Running $TESTING/update_cleanup.php\007\003\n"
	[ -f $TESTING/update_cleanup.php ] && $PHP $TESTING/update_cleanup.php
	printf "\033]0; Loop $LOOP - Running $TESTING/update_parsing.php\007\003\n"
	[ -f $TESTING/update_parsing.php ] && $PHP $TESTING/update_parsing.php
fi

#increment backfill days
$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD1"


DIFF=$(($CURRTIME-$LASTOPTIMIZE2))
if [ "$DIFF" -gt 43200 ] || [ "$DIFF" -lt 1 ]
then
	LASTOPTIMIZE2=`date +%s`
	printf "\033]0; Loop $LOOP - Running $NEWZNAB_PATH/optimise_db.php\007\003\n"
	cd $NEWZNAB_PATH
	[ -f $NEWZNAB_PATH/optimise_db.php ] && $PHP $NEWZNAB_PATH/optimise_db.php true
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


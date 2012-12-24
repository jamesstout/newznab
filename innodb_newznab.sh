#!/bin/sh
##******************ONLY IF YOU HAVE CONVERTED YOUR TABLE TO InnoDB**********************

# call this script from within screen to get binaries, processes releases and 
# every half day get tv/theatre info and optimise the database

set -e

export NEWZNAB_PATH='/var/www/newznab/misc/update_scripts'
export INNODB_PATH='/var/www/newznab/misc/testing/innodb'
export NEWZNAB_SLEEP_TIME='10' # in seconds
export NZBS='/path/to/nzbs'  #path to your nzb files
export MyUSER='root' #mysql user
export MyPASS='password' #mysql password
export DATABASE='newznab'
export MAXDAYS='180'  #max days for backfill
export MAXRET='2'  #max days for backfill
export MYSQL="$(which mysql)"
export MYSQL_CMD1="UPDATE groups set backfill_target=backfill_target+1 where active=1 and backfill_target<$MAXDAYS;"
export MYSQL_CMD2="UPDATE site set value=$MAXRET where setting='rawretentiondays';"
export MYSQL_CMD3="UPDATE site set value=0 where setting='rawretentiondays';"

LASTOPTIMIZE1=`date +%s`
LASTOPTIMIZE2=`date +%s`

while :

 do
CURRTIME=`date +%s`
cd $NEWZNAB_PATH
#update regex's and clear any unfinished work from previous runs
[ -f $NEWZNAB_PATH/update_releases.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_releases.php

#set retention days
$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD2"

#make active groups current
cd $INNODB_PATH
[ -f $NEWZNAB_PATH/update_binaries.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_binaries.php
cd $NEWZNAB_PATH
[ -f $NEWZNAB_PATH/update_releases.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_releases.php

#set retention days to 0
$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD3"

#import nzb's
cd $INNODB_PATH
[ -f $NEWZNAB_PATH/nzb-import.php ] && /usr/bin/php5 $NEWZNAB_PATH/nzb-import.php ${NZBS} true
cd $NEWZNAB_PATH
[ -f $NEWZNAB_PATH/update_releases.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_releases.php

#get backfill for all active groups
cd $INNODB_PATH
[ -f $NEWZNAB_PATH/backfill.php ] && /usr/bin/php5 $NEWZNAB_PATH/backfill.php
cd $NEWZNAB_PATH
[ -f $NEWZNAB_PATH/update_releases.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_releases.php

#reset retention days
$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "$MYSQL_CMD2"

DIFF=$(($CURRTIME-$LASTOPTIMIZE1))
if [ "$DIFF" -gt 7200 ] || [ "$DIFF" -lt 1 ]
then
	LASTOPTIMIZE1=`date +%s`
	#run some cleanup scripts
	[ -f $NEWZNAB_PATH/update_predb.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_predb.php true
	[ -f $NEWZNAB_PATH/removespecial.php ] && /usr/bin/php5 $NEWZNAB_PATH/removespecial.php
	[ -f $NEWZNAB_PATH/update_cleanup.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_cleanup.php
	[ -f $NEWZNAB_PATH/update_parsing.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_parsing.php
fi

#increment backfill days
$MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "${MYSQL_CMD1}"


DIFF=$(($CURRTIME-$LASTOPTIMIZE2))
if [ "$DIFF" -gt 43200 ] || [ "$DIFF" -lt 1 ]
then
	LASTOPTIMIZE2=`date +%s`
	[ -f $NEWZNAB_PATH/optimise_db.php ] && /usr/bin/php5 $NEWZNAB_PATH/optimise_db.php
	[ -f $NEWZNAB_PATH/update_tvschedule.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_tvschedule.php
	[ -f $NEWZNAB_PATH/update_theaters.php ] && /usr/bin/php5 $NEWZNAB_PATH/update_theaters.php
fi

echo "waiting $NEWZNAB_SLEEP_TIME seconds..."
sleep $NEWZNAB_SLEEP_TIME

done


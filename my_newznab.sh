#!/bin/sh
# call this script from within screen to get binaries, processes releases and 
# every half day get tv/theatre info and optimise the database

set -e

export NEWZNAB_PATH="/var/www/newznab/misc/update_scripts"
export NEWZNAB_ADMIN_PATH="/var/www/newznab/www/admin"
export NEWZNAB_SLEEP_TIME="10" # in seconds
export NZBS="/media/newznab/batch"  #path to your nzb files
export MyUSER="root" #mysql user
export MyPASS="dfgrfgurge" #mysql password
export DATABASE="newznab"
export MAXDAYS=730  #max days for backfill
export MYSQL="$(which mysql)"
export MYSQL_CMD="UPDATE groups set backfill_target=backfill_target+1 where active=1 and backfill_target<$MAXDAYS;"

LASTOPTIMIZE=`date +%s`

while :

 do
CURRTIME=`date +%s`
cd ${NEWZNAB_PATH}
/usr/bin/php5 ${NEWZNAB_PATH}/update_binaries_threaded.php
/usr/bin/php5 ${NEWZNAB_PATH}/update_releases.php
/usr/bin/php5 ${NEWZNAB_ADMIN_PATH}/nzb-importmodified.php ${NZBS} true
/usr/bin/php5 ${NEWZNAB_PATH}/update_releases.php
/usr/bin/php5 ${NEWZNAB_PATH}/backfill_threaded.php
/usr/bin/php5 ${NEWZNAB_PATH}/update_releases.php
/usr/bin/php5 ${NEWZNAB_PATH}/update_parsing.php
/usr/bin/php5 ${NEWZNAB_PATH}/update_cleanup.php
/usr/bin/php5 ${NEWZNAB_PATH}/removespecial.php
${MYSQL} -u ${MyUSER} -p${MyPASS} ${DATABASE} -e "${MYSQL_CMD}"

DIFF=$(($CURRTIME-$LASTOPTIMIZE))
if [ "$DIFF" -gt 43200 ] || [ "$DIFF" -lt 1 ]
then
	LASTOPTIMIZE=`date +%s`
	/usr/bin/php5 ${NEWZNAB_PATH}/optimise_db.php
	/usr/bin/php5 ${NEWZNAB_PATH}/update_tvschedule.php
	/usr/bin/php5 ${NEWZNAB_PATH}/update_theaters.php
fi

echo "waiting ${NEWZNAB_SLEEP_TIME} seconds..."
sleep ${NEWZNAB_SLEEP_TIME}

done

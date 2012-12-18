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
export MAXDAYS=180  #max days for backfill
export MAXRET=2  #max days for backfill
export MYSQL="$(which mysql)"
export MYSQL_CMD1="UPDATE groups set backfill_target=backfill_target+1 where active=1 and backfill_target<$MAXDAYS;"
export MYSQL_CMD2="UPDATE site set value=$MAXRET where setting='rawretentiondays';"
export MYSQL_CMD3="UPDATE site set value=0 where setting=;rawretentiondays';"

LASTOPTIMIZE=`date +%s`

while :

 do
CURRTIME=`date +%s`
cd ${NEWZNAB_PATH}
${MYSQL} -u ${MyUSER} -p${MyPASS} ${DATABASE} -e "${MYSQL_CMD2}"
/usr/bin/php5 ${NEWZNAB_PATH}/update_binaries_threaded.php
/usr/bin/php5 ${NEWZNAB_PATH}/update_releases.php
${MYSQL} -u ${MyUSER} -p${MyPASS} ${DATABASE} -e "${MYSQL_CMD3}"
/usr/bin/php5 ${NEWZNAB_ADMIN_PATH}/nzb-importmodified.php ${NZBS} true
/usr/bin/php5 ${NEWZNAB_PATH}/update_releases.php
/usr/bin/php5 ${NEWZNAB_PATH}/backfill_threaded.php
/usr/bin/php5 ${NEWZNAB_PATH}/update_releases.php
${MYSQL} -u ${MyUSER} -p${MyPASS} ${DATABASE} -e "${MYSQL_CMD2}"
/usr/bin/php5 ${NEWZNAB_PATH}/update_predb.php true
/usr/bin/php5 ${NEWZNAB_PATH}/update_parsing.php
/usr/bin/php5 ${NEWZNAB_PATH}/removespecial.php
/usr/bin/php5 ${NEWZNAB_PATH}/update_cleanup.php
${MYSQL} -u ${MyUSER} -p${MyPASS} ${DATABASE} -e "${MYSQL_CMD1}"


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

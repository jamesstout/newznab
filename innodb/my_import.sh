#!/bin/sh
##******************ONLY IF YOU HAVE CONVERTED YOUR TABLE TO InnoDB**********************
##**********************WARNING - YOU MAY NOT LIKE THE RESULTS***************************

# run this and update binaries, processes releases and
# every half day get tv/theatre info and optimise the database
# every 2 hours run cleanup scripts

# These scripts are constantly changing (still learning). If something doesn't work as expected /msg jonnyboy on irc.
# Tell me what is broken and I'll check and fix if necessary.

# I have tested this with all of the tables converted to InnoDB, not just parts and binaries.

# These scripts make changes to the default newznab files, svn up'dating you newznab install will require to rerun the
# setup script.
# These scripts will create a tmux session and run several scripts at once. The bottleneck is postprocessing
# the releases is doing all of the lookups for all of the releases, while on after the other. These scripts change that.
# I have removed all of the lookups to thier own script and they run independantly of the other scripts.

# What will actually be running, separately and at the same time:
# nzb-import - imports nzb's backfills and gets current - loops
# processNfos
# processing - all of the othe postprocessing scripts
# processAdditional
# update_releases and the cleanup scripts in a loop

# Setup: do not set your retention days to 0, the import

set -e

##EDIT AS NECESSARY##

export INNODB_PATH='/var/www/newznab/misc/testing/innodb'
export NEWZNAB_PATH='/var/www/newznab/misc/update_scripts'
export NEWZNAB_SLEEP_TIME='10' # in seconds
export NZBS='/path/to/nzbs'  #path to your nzb files to be imported
export MyUSER='root' #mysql user
export MyPASS='password' #mysql password
export DATABASE='newznab'
export MAXDAYS='200'  #max days for backfill
export MYSQL="$(which mysql)"
export PHP="$(which php5)"
export MYSQL_CMD="UPDATE groups set backfill_target=backfill_target+1 where active=1 and backfill_target<$MAXDAYS;"

##END OF EDITS##


while :
 do

    #import nzb's
    cd $INNODB_PATH
    [ -f $INNODB_PATH/nzb-import.php ] && $PHP $INNODB_PATH/nzb-import.php ${NZBS} &

    #make active groups current
    cd $NEWZNAB_PATH
    [ -f $NEWZNAB_PATH/update_binaries_threaded.php ] && $PHP $NEWZNAB_PATH/update_binaries_threaded.php &

    #get backfill for all active groups
    cd $NEWZNAB_PATH
    [ -f $NEWZNAB_PATH/backfill_threaded.php ] && $PHP $NEWZNAB_PATH/backfill_threaded.php &

    wait

    #increment backfill days
    $MYSQL -u$MyUSER --password=$MyPASS $DATABASE -e "${MYSQL_CMD}"

    echo "imports waiting $NEWZNAB_SLEEP_TIME seconds..."
    sleep $NEWZNAB_SLEEP_TIME

done


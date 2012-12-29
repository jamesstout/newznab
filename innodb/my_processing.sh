
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

export NEWZNAB_PATH='/var/www/newznab/misc/update_scripts'
export TESTING='/var/www/newznab/misc/testing'
export NEWZNAB_SLEEP_TIME='1' # in seconds
export PHP="$(which php5)"

##END OF EDITS##

LASTOPTIMIZE1=`date +%s`
LASTOPTIMIZE2=`date +%s`
LASTOPTIMIZE3=`date +%s`
while :

 do

#create releases from binaries
cd $NEWZNAB_PATH
[ -f $NEWZNAB_PATH/update_releases.php ] && $PHP $NEWZNAB_PATH/update_releases.php

CURRTIME=`date +%s`
#every 2 hours and during first loop
DIFF=$(($CURRTIME-$LASTOPTIMIZE1))
if [ "$DIFF" -gt 3600 ] || [ "$DIFF" -lt 1 ]
then
        LASTOPTIMIZE1=`date +%s`
        cd $NEWZNAB_PATH
        [ -f $NEWZNAB_PATH/update_predb.php ] && $PHP $NEWZNAB_PATH/update_predb.php true
        cd $TESTING
        [ -f $TESTING/update_parsing.php ] && $PHP $TESTING/update_parsing.php
        [ -f $TESTING/removespecial.php ] && $PHP $TESTING/removespecial.php
        [ -f $TESTING/update_cleanup.php ] && $PHP $TESTING/update_cleanup.php
fi

CURRTIME=`date +%s`
#every 12 hours
DIFF=$(($CURRTIME-$LASTOPTIMIZE2))
if [ "$DIFF" -gt 43200 ]
then
        LASTOPTIMIZE2=`date +%s`
        cd $NEWZNAB_PATH
        [ -f $NEWZNAB_PATH/optimise_db.php ] && $PHP $NEWZNAB_PATH/optimise_db.php
fi

CURRTIME=`date +%s`
#every 12 hours and during 1st loop
DIFF=$(($CURRTIME-$LASTOPTIMIZE2))
if [ "$DIFF" -gt 43200 ] || [ "$DIFF" -lt 1 ]
then
        LASTOPTIMIZE3=`date +%s`
        cd $NEWZNAB_PATH
        #[ -f $NEWZNAB_PATH/optimise_db.php ] && $PHP $NEWZNAB_PATH/optimise_db.php true
        [ -f $NEWZNAB_PATH/update_tvschedule.php ] && $PHP $NEWZNAB_PATH/update_tvschedule.php
        [ -f $NEWZNAB_PATH/update_theaters.php ] && $PHP $NEWZNAB_PATH/update_theaters.php
fi

echo "waiting $NEWZNAB_SLEEP_TIME seconds..."
sleep $NEWZNAB_SLEEP_TIME

done


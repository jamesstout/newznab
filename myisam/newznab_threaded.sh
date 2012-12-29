#!/bin/sh
##**********************WARNING - YOU MAY NOT LIKE THE RESULTS***************************

# run this and update binaries, processes releases and
# every half day get tv/theatre info and optimise the database
# every 2 hours run cleanup scripts

# These scripts are constantly changing (still learning). If something doesn't work as expected /msg jonnyboy on irc.
# Tell me what is broken and I'll check and fix if necessary.

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

# Setup: do not set your retention days to 0, the parts table may get a big, but doing so will delete parts to releases
# that have not had the time to complete

set -e

##EDIT AS NECESSARY##

export NEWZNAB_PATH='/var/www/newznab/misc/update_scripts'
export NEWZNAB_ADMIN_PATH='/var/www/newznab/www/admin'
export TESTING='/var/www/newznab/misc/testing'
export NEWZNAB_SLEEP_TIME='1' # in seconds
export NZBS='/path/to/nzbs'  #path to your nzb files to be imported
export MyUSER='root' #mysql user
export MyPASS='password' #mysql password
export DATABASE='newznab'
export MAXDAYS='200'  #max days for backfill
export MYSQL="$(which mysql)"
export PHP="$(which php5)"
export TMUX="$(which tmux)"
export SCREEN="$(which screen)"
export MYSQL_CMD="UPDATE groups set backfill_target=backfill_target+1 where active=1 and backfill_target<$MAXDAYS;"

##END OF EDITS##

#check for files and exit if not found
[ ! -f $NEWZNAB_PATH/justpostprocessing.php ] && echo $NEWZNAB_PATH/justpostprocessing.php not found && exit
[ ! -f $NEWZNAB_PATH/postprocess_nfo.php ] && echo $NEWZNAB_PATH/postprocess_nfo.php not found && exit
[ ! -f $NEWZNAB_PATH/postprocessing.php ] && echo $NEWZNAB_PATH/postprocessing.php not found && exit
[ ! -f $NEWZNAB_PATH/update_binaries_threaded.php ] && echo $NEWZNAB_PATH/update_binaries_threaded.php not found && exit
[ ! -f $NEWZNAB_PATH/backfill_threaded.php ] && echo $NEWZNAB_PATH/backfill_threaded.php not found && exit
[ ! -f $NEWZNAB_PATH/update_releases.php ] && echo $NEWZNAB_PATH/update_releases.php not found && exit
[ ! -f $NEWZNAB_PATH/update_predb.php ] && echo $NEWZNAB_PATH/update_predb.php not found && exit
[ ! -f $NEWZNAB_ADMIN_PATH/nzb-importmodified.php ] && echo $NEWZNAB_ADMIN_PATH/nzb-importmodified.php not found && exit
[ ! -f $TESTING/removespecial.php ] && echo $TESTING/removespecial.php not found && exit
[ ! -f $TESTING/update_cleanup.php ] && echo $TESTING/update_cleanup.php not found && exit
[ ! -f $TESTING/update_parsing.php ] && echo $TESTING/update_parsing.php not found && exit
[ ! -f $NEWZNAB_PATH/optimise_db.php ] && echo $NEWZNAB_PATH/optimise_db.php not found && exit
[ ! -f $NEWZNAB_PATH/update_tvschedule.php ] && echo $NEWZNAB_PATH/update_tvschedule.php not found && exit
[ ! -f $NEWZNAB_PATH/update_theaters.php ] && echo $NEWZNAB_PATH/update_theaters.php not found && exit


# sleep's are so the update_releases can get a running start before getting slammed

$TMUX new-session -d -s NewzNab -n NewzNab 'cd $NEWZNAB_PATH && echo "processNfos Working......" && sleep 30 && $PHP $NEWZNAB_PATH/postprocess_nfo.php'
$TMUX selectp -t 0
$TMUX splitw -v -p 75 'echo "imports Working......" && sleep 45 && ./my_import.sh'
$TMUX selectp -t 0
$TMUX splitw -h -p 66 'cd $NEWZNAB_PATH && echo "processAdditional Working......" && sleep 35 && $PHP $NEWZNAB_PATH/justpostprocessing.php'
$TMUX splitw -h -p 50 'cd $NEWZNAB_PATH && echo "postProcessing Working......" && sleep 40 && $PHP $NEWZNAB_PATH/postprocessing.php'
$TMUX selectp -t 3
$TMUX splitw -h -p 50 'echo "create Releases Working......" && ./my_processing.sh'

$TMUX select-window -tNewzNab:0
$TMUX attach-session -d -tNewzNab


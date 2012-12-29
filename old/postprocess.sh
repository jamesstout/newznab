#!/bin/bash
# run this script as su or sudo
# it will modify lib/postprocess.php to run only once
# it will modify lib/releases.php to not run lib/postprocess.php
# it will download justpostprocessing.php and place it in the correct location
# this will remove the post processing to it's own loop
# and will signaificantly decrease time per loop using my scrips
# original idea from https://sites.google.com/site/1204nnplus/optional-configurations
# and http://pastebin.com/rP9nUhz8

# Set these variables - case significant
NEWZPATH=/var/www/newznab
WGET=`which wget`
SED=`which sed`

$WGET -N -O $NEWZPATH/misc/update_scripts/justpostprocessing.php https://dl.dropbox.com/u/8760087/justpostprocessing.php
#$SED -i -e 's/$numtoProcess = 100;/$numtoProcess = 1;/g' $NEWZPATH/www/lib/postprocess.php
#$SED -i -e 's/$postprocess = new PostProcess(true);/\/\/$postprocess = new PostProcess(true);/' $NEWZPATH/www/lib/releases.php
#$SED -i -e 's/$postprocess->processAll();/\/\/$postprocess->processAll();/' $NEWZPATH/www/lib/releases.php
$SED -i -e 's/$this->processAdditional();/\/\/$this->processAdditional();/' $NEWZPATH/www/lib/postprocess.php

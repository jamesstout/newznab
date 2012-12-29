#!/bin/bash
# run this script as su or sudo
# it will modify lib/postprocess.php to run only once
# it will download 3 files and place it in the correct location
# this will remove the post processing to it's own loop
# and will signaificantly decrease time per loop using my scrips
# original idea from https://sites.google.com/site/1204nnplus/optional-configurations
# and http://pastebin.com/rP9nUhz8

# Set these variables - case significant
NEWZPATH=/var/www/newznab
SED=`which sed`

cp justpostprocessing.php $NEWZPATH/misc/update_scripts/
cp postprocessing.php $NEWZPATH/misc/update_scripts/
cp postprocess_nfo.php $NEWZPATH/misc/update_scripts/
[ -f ~/.tmux.conf ] && mv .tmux.conf .tmux.conf.orig
cp tmux.conf ~/.tmux.conf
$SED -i -e 's/$this->processAdditional();/\/\/$this->>processAdditional();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processNfos();/\/\/$this->processNfos();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processUnwanted();/\/\/$this->processUnwanted();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processMovies();/\/\/$this->processMovies();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processMusic();/\/\/$this->processMusic();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processBooks();/\/\/$this->processBooks();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processGames();/\/\/$this->processGames();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processTv();/\/\/$this->processTv();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processMusicFromMediaInfo();/\/\/$this->processMusicFromMediaInfo();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processOtherMiscCategory();/\/\/$this->processOtherMiscCategory();/' $NEWZPATH/www/lib/postprocess.php
$SED -i -e 's/$this->processUnknownCategory();/\/\/$this->processUnknownCategory();/' $NEWZPATH/www/lib/postprocess.php


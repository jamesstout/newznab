Newznab all in one script

Be sure to edit the paths, the mysql username, password and database.

Copy nzb-importmodified.php to www/admin/ and edit as needed.

Copy update_parsing.php to misc/update_scripts/ and edit as needed.

You can run this in screen or from cron.


What this script does:
1) run update_binaries_threaded.php pulls binaries for all active groups.
2) run update_releases.php to create releases form binaries.
3) run nzb-importmodified.php and import 100 nzbs from local filesystem.
4) run update_releases.php to create releases form binaries.
5) run backfill_threaded.php to pull backfills upto current backfill_max.
6) run update_releases.php to create releases form binaries.
7) run update_parsing.php to turn some of those hashed titles into proper release.
8) run ${MYSQL} -u ${MyUSER} -p${MyPASS} ${DATABASE} -e "${MYSQL_CMD}" to increment the backfill by 1.
9) Wash and repeat.


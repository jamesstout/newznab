These scripts are constantly changing (still learning). If something doesn't work as expected 
/msg jonnyboy on irc. Tell me what is broken and I'll check and fix if necessary.

**Newznab all in one Script**

Be sure to edit the paths, the mysql username, password, database, retention and backfill days.

Copy nzb-importmodified.php to www/admin/ and edit as needed.

Enter the details for nzpre and set you retention days.

You can run this in screen or from cron.


What this script does:

1.  Set retention=what you set.
2.  run `update_binaries_threaded.php` to pull binaries for all active groups.
3.  run `update_releases.php` to create releases form binaries.
4.  run `nzb-importmodified.php` and import 100 nzbs from local filesystem.
5.  run `update_releases.php` to create releases form binaries.
6.  Set retention=0.
7.  run `backfill_threaded.php` to pull backfills upto current backfill.
8.  run `update_releases.php` to create releases form binaries.
9.  Reset retention back to what you set.
10. run `update_predb.php true` to use the nzpre info.
11. run `removespecial.php` to do some more *cleanup*. 
12. run `update_cleanup.php` to do some *cleanup*.
13. run `update_parsing.php` to turn some of those hashed titles into a proper release.
14. Increment the backfill for all active groups by 1.
15. Wash and repeat.

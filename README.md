These scripts are constantly changing (still learning). If something doesn't work as expected 
/msg jonnyboy on irc. Tell me what is broken and I'll check and fix if necessary.

I have include my innodb my.cnf, if you see something that is out of whack or may be better configured,
please msg me.

**Newznab all in one Script**


*IMPORTANT*

Be sure to edit the paths, the mysql username, password, database, retention and backfill days.

Read the files in misc/testing and edit as needed. 'update_cleanup.php' will not do anything without editing the file first.

Copy nzb-importmodified.php to www/admin/ and edit as needed.

Enter the details for nzpre and set you retention days.

You can run these in screen or from cron.
innodb_newznab.sh         --> InnoDB tables
my_newznab.sh             --> Threaded downloading using MyIsam tables
my_newznab_no_threads.sh  --> Non Threaded downloading using MyIsam tables

Run postprocess.sh, as root, to create a new file to remove postprocessing to it's own process. this will significantly decrease time per loop.

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

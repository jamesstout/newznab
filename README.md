These scripts are constantly changing (still learning). If something doesn't work as expected 
/msg jonnyboy on irc. Tell me what is broken and I'll check and fix if necessary.

I have include my innodb my.cnf, if you see something that is out of whack or may be better configured,
please msg me.

**Newznab all in one Script**


*IMPORTANT*

Be sure to edit the paths, the mysql username, password, database name and backfill days.

Read the files in misc/testing and edit as needed. 'update_cleanup.php' will not do anything without editing the file first.

Copy nzb-importmodified.php to www/admin/ and edit as needed.

Enter the details for nzpre.

You can run these in screen or from cron.
* innodb_newznab.sh         -- InnoDB tables.
* my_newznab.sh             -- Threaded downloading using MyIsam tables.
* my_newznab_no_threads.sh  -- Non Threaded downloading using MyIsam tables.

Run postprocess.sh, as root, to create a new file to remove postprocessing to it's own process. this will significantly decrease time per loop.

To use the innodb script, you will need to clone the repo https://github.com/itandrew/Newznab-InnoDB-Dropin.git into misc/testing/
This will make his scripts available and able to be run.

What my_newznab.sh does (the others do similar):

Each loop:

1.  run `update_releases.php` to cleanup from previous runs
2.  run `justpostprocessing.php` in screen, this does all of the postprocessing if you have run postprocess.sh.
3.  run `update_binaries_threaded.php` to pull binaries for all active groups.
4.  run `update_releases.php` to create releases form binaries.
5.  run `nzb-importmodified.php` and import 100 nzbs from local filesystem.
6.  run `update_releases.php` to create releases form binaries.
7.  run `backfill_threaded.php` to pull backfills upto current backfill.
8.  run `update_releases.php` to create releases form binaries.
Every 2 hours, postprocessing cleanup:

9.  run `update_predb.php`
10. run `update_parsing.php`
11. run `removespecial.php`
12. run `update_cleanup.php`
Every 12 hours:

13. run `optimise_db.php`
14. run `update_tvschedule.php`
15. run `update_theaters.php`
At end of loop:

16. Increment the backfill for all active groups by 1 up to the MAXDAYS set.
17. Wash and repeat.

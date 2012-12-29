# SETUP

 * Please backup your database first. Something like this should do it.

    `mysqldump --opt -u root -p newznab > ~/newznab_backup.sql`

 * Create a folder.
 * Move to that folder.
 * Clone my github

    `git clone https://github.com/jonnyboy/newznab.git`
    
    `cd newznab/myisam`
    
    `nano setup.sh`

 * Edit the root of the path to you Newznab installation.
 * Save and exit.

    `nano newznab_threaded.sh`

 * Read and edit as necessary.
 * Save and exit.

    `nano my_import.sh`

 * Read and edit as necessary.
 * Save and exit.

    `nano my_processing.sh`

 * Read and edit as necessary.
 * Save and exit.

 * Run my setup script to make a few edits and download 3 new files.

    `./setup.sh`

 * Run my script.

    `./newznab_threaded.sh`
    
 * If you connect using putty, then under Window/Translation set Remote character set to UTF-8.

 * If something looks stalled, it probably isn't. If all 5 panes are still there, it is most likely, as it should be.

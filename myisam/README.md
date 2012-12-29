# SETUP

 * Create a folder.
 * Move to that folder.
 * Clone my github

    `git clone https://github.com/jonnyboy/newznab.git`
    
    `cd newznab/innodb`
    
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

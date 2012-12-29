# SETUP
### This assumes that you have already setup your install using [andrewit's github](https://github.com/itandrew/Newznab-InnoDB-Dropin.git) If not, please do that first.

 * Create a folder.
 * Move to that folder.
 * Clone my github

    git clone https://github.com/jonnyboy/newznab.git
    cd newznab
    nano innodb-setup.sh

 * Edit the root of the path to you Newznab installation.
 * Save and exit.

    nano innodb_threaded.sh

 * Read and edit as necessary.
 * Save and exit.

    nano my_import.sh

 * Read and edit as necessary.
 * Save and exit.

    nano my_processing.sh

 * Read and edit as necessary.
 * Save and exit.

 * Run my setup script to make a few edits and download 3 new files.

    innodb-setup.sh

 * Run my script.

    innodb_threaded.sh


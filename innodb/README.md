# SETUP

 * This assumes that you have already setup your install using [andrewit's github](https://github.com/itandrew/Newznab-InnoDB-Dropin.git) If not, please do that first.
 * convert database to innodb

    `create a folder and move to it`    
    
    `wget -N https://dl.dropbox.com/u/8760087/innodb.sh`
    
    `chmod +x innodb.sh`
    
    `./innodb.sh`

 * Create a folder.
 * Move to that folder.
 * Clone my github

    `git clone https://github.com/jonnyboy/newznab.git`
    
    `cd newznab/innodb`
    
    `nano innodb-setup.sh`


 * Edit the root of the path to you Newznab installation.
 * Save and exit.

    `nano innodb_threaded.sh`

 * Read and edit as necessary.
 * Save and exit.

    `nano my_import.sh`

 * Read and edit as necessary.
 * Save and exit.

    `nano my_processing.sh`

 * Read and edit as necessary.
 * Save and exit.

 * Run my setup script to make a few edits and download 3 new files.

    `./innodb-setup.sh`

 * Run my script.

    `./innodb_threaded.sh`
    
    
 * If you do not have a tmux.conf file in your home folder, you can use mine. Run this as the user you will run the script with.

    `wget -N ~/tmux.conf https://dl.dropbox.com/u/8760087/tmux.conf`
    
    `mv ~/tmux.conf ~/.tmux.conf`
    
 * If you connect using putty, then under Window/Translation set Remote character set to UTF-8.

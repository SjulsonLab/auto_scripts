#!/bin/bash

# this backs up your home directory on you workstation SSD to the NAS
# if the SOURCEDIR has a slash at the end, rsync will copy everything inside that
# folder, but it won't copy the folder itself.
SOURCEDIR="/home/luke/"
DREADDMOUNT="/mnt/dreadd/bbslab" # where "renata-lukelab" is mounted
BACKUPDIR="workstation_backups/luke" # where to copy it to




# this if statement tests whether renata-lukelab is actually mounted
if mount | grep "renata-lukelab" | grep $DREADDMOUNT > /dev/null ; then 
#	./rsync_tmbackup.sh --rsync-set-flags "--exclude '*.dat' --exclude '.phy' --safe-links --progress" $SOURCEDIR $DREADDMOUNT/$BACKUPDIR
#	./rsync_tmbackup.sh --rsync-set-flags "--exclude '*.dat' --exclude '.phy' --progress" $SOURCEDIR $DREADDMOUNT/$BACKUPDIR

	rsync -av --exclude '*.dat' --exclude '.phy' --exclude '.cache' --exclude '.config' --exclude '.dropbox*' --safe-links $SOURCEDIR $DREADDMOUNT/$BACKUPDIR
else 
	wall "NAS is not mounted! System was not backed up on `date`"
fi

# Note: this will NOT backup symlinks outside of SOURCEDIR's tree, i.e. if you have
# a link to Dropbox on your laptop, your dropbox folder will not be backed up.
# If you have a symlink to a second SSD inside your home directory, it will NOT be
# backed up. However, if the second SSD's mount point (in /etc/fstab) is inside
# your home directory tree, it WILL be backed up.
# Another important thing is that rsync is nondestructive copy, meaning if you back
# up files to the NAS and then delete them off of your local SSD (e.g. .lfp files),
# the files will NOT be deleted off of the NAS.

# if you want to back up something else you can add it here
#SOURCEDIR="/mnt/workspace"
#DREADDBACKUP="/mnt/dreadd/luke/backup" # where to copy the files to
#rsync -av --exclude '*.dat' --exclude '.phy' --safe-links $SOURCEDIR $DREADDBACKUP



############ to install this script
# cd
# mkdir scripts
#### (save this script in there, named daily_backup)
# chmod u+x daily_backup
#### add this line to your .bash_profile (or .profile if you don't have a .bash_profile)
# export PATH="$PATH:$HOME/scripts"      # add your scripts directory to the path
#### after that, either reopen your terminal or:
# source ~/.bash_profile     (or ~/.profile)

############ to launch it manually (for testing)
# daily_sync

############ to make it run automatically
# crontab -e       (edit your crontab - don't use sudo)
# select-editor    (if you haven't done this already. Select nano)
##### add this line (without the #) to run the script daily at 3AM:
# 0 3 * * *      /home/luke/scripts/daily_backup
##### control-X to save and exit, and you're done




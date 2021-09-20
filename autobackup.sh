#!/bin/bash

# autobackup.sh
#
# usage: modify the parameters to customize it for your machine, then test it with TESTRUN=true
# then eventually TESTRUN false. When you're satisfied that it is working, add it to your crontab
# using
#
# crontab -e
# (select nano as your editor)
#
# then add the line:
# 15 3 * * * /home/luke/autobackup/autobackup.sh >> /home/luke/autobackup/autobackup.log
#
# which will run the script every day at 3:15 AM. We should stagger our backups so that
# only one user is backing up their data at a time. 
#
# Luke Sjulson 2021-09-17 (with contribution from Maurice Volaski)


# examples:
# BACKUPDIR='/home/luke' # the name of the directory to backup
# NASDIR='/mnt/NAS/luke/autobackup' # where to backup the directory tree

# DO NOT include trailing slashes for either directory name
BACKUPDIR='/home/pi'
NASDIR='/mnt/NAS/luke/autobackup'

MOUNTSTRING='dreadd'  # if this string does not show up in the list of mounted drives, the script will abort
TESTRUN=false        # if true, nothing actually gets backed up

# if there's anything else you want to exclude from backups, add it here
EXCLUDE={'*.dat','.phy','.cache','.config','.dropbox*'} 

# Note: this will NOT backup symlinks outside of BACKUPDIR's tree, i.e. if you have
# a link to Dropbox on your laptop, your dropbox folder will not be backed up.
# If you have a symlink to a second SSD inside your home directory, it will NOT be
# backed up. However, if the second SSD's mount point (in /etc/fstab) is inside
# your home directory tree, it WILL be backed up.
# Another important thing is that rsync is nondestructive copy, meaning if you back
# up files to the NAS and then delete them off of your local SSD (e.g. .lfp files),
# the files will NOT be deleted off of the NAS. The NAS therefore stores a backup 
# of any file that has ever been in your BACKUPDIR.

####################################
# INSTALLATION INSTRUCTIONS

# 1. Create and mount your backup location on dreadd
# - create your mount point
# $ sudo mkdir /mnt
# $ sudo mkdir /mnt/NAS
# $ sudo mkdir /mnt/NAS/lab
# $ sudo mkdir /mnt/NAS/luke
# 
# - figure out your UID and GID
# $ grep luke /etc/passwd
# - result:     luke:x:1000:1000:,,,:/home/luke:/bin/bash
# - your UID (user ID) and GID (group ID) are both 1000
#
# next edit your fstab (filesystem tab) to add the dreadd shares
# $ sudo nano /etc/fstab
# and add these lines
# //dreadd.montefiore.org/renata-lukelab /mnt/NAS/lab cifs username=luke,password=*****,iocharset=utf8,sec=ntlmssp,vers=2.0,uid=1000,gid=1000 0 0 
# //dreadd.montefiore.org/luke /mnt/NAS/luke cifs username=luke,password=*****,iocharset=utf8,sec=ntlmssp,vers=2.0,uid=1000,gid=1000 0 0 
# replace "luke" with your username, ***** with your password, and 1000 with your uid and gid

############ to install this script
# $ cd
# $ mkdir autobackup
#### (save this script in there, named autobackup.sh)
# $ cd ~/autobackup
# $ chmod u+x autobackup.sh
#### add this line to your .bash_profile (or .profile if you don't have a .bash_profile)
# export PATH="$PATH:$HOME/autobackup"      # add your autobackup directory to the path
#### after that, either reopen your terminal or:
# $ source ~/.bash_profile     (or ~/.profile)

############ to launch it manually (for testing)
# autobackup.sh

############ to make it run automatically
# $ crontab -e       (edit your crontab - don't use sudo)
# select-editor    (if you haven't done this already. Select nano)
##### add this line (without the #) to run the script daily at 3:15 AM:
# 15 3 * * *      /home/luke/autobackup/autobackup.sh >> /home/luke/autobackup/autobackup.log
##### control-X to save and exit, and you're done
# we should stagger the backups so that only one computer is being backed up at any given time



#######################################################
# no user-editable parameters below this line
#######################################################


echo '##########################################################################'
echo '#          Autobackup starting' `date`
echo '##########################################################################'
echo
echo BACKUPDIR: $BACKUPDIR
echo NASDIR: $NASDIR
echo MOUNTSTRING: $MOUNTSTRING
echo TESTRUN: $TESTRUN
echo EXCLUDING: $EXCLUDE 

# test if dreadd is mounted - if not, don't do backup
/usr/bin/df | /usr/bin/grep $MOUNTSTRING
if [ ${?} -eq 0 ] ; then

	eval /usr/bin/rsync -v -a --progress --exclude=$EXCLUDE --safe-links \
	--itemize-changes --no-perms --no-owner --stats \
	$BACKUPDIR $NASDIR
	echo	
	echo '##########################################################################'
	echo '#          Autobackup completed' `date`
	echo '##########################################################################'
	echo
else
        echo 
	echo '##########################################################################'
        echo "#          ERROR - $MOUNTSTRING NOT FOUND!"
	echo '##########################################################################'
	wall "Daily backup failed! Ensure $MOUNTSTRING is mounted and run autobackup.sh again"
        echo
fi

echo
echo
echo

#!/bin/bash

# move-datfile.sh
#
# usage: move-datfile.sh DIRNAME
# 
# where DIRNAME is the name of a directory containing .dat files. This script will generate an
# empty directory tree of BACKUPDIR and move the dat files in DIRNAME into it.
#
# Luke Sjulson 2021-09-17 (with contribution from Maurice Volaski)


# examples:
# BACKUPDIR='/home/pi/' # the name of the directory to backup
# NASDIR='/mnt/NAS/lab/dat_files/luke/pi/' # where to backup the directory tree
# note that the pi directory is present in both BACKUPDIR and NASDIR

# include trailing slashes for both directory names
BACKUPDIR='/home/pi/' # the name of the directory to backup
NASDIR='/mnt/NAS/lab/dat_files/luke/pi/' # where to backup the directory tree

MOUNTSTRING='dreadd'  # if this string does not show up in the list of mounted drives, the script will abort
FILENAME='DATmove.log' # the name of the logfile

TESTRUN=false        # if true, dat files do not get copied, but directory tree is still made
MOVEDATFILES=false  # if false, the dat files are copied instead of moved

#######################################################
# no user-editable parameters below this line
#######################################################

# figure out source path
cd $1
SOURCEDIR=$PWD

echo 'Moving DAT files off of workstation, starting' `date` | tee -a $FILENAME
echo TESTRUN = $TESTRUN | tee -a $FILENAME
echo MOVEDATFILES = $MOVEDATFILES | tee -a $FILENAME
echo sourcedir: $SOURCEDIR | tee -a $FILENAME

# figure out middle part of path
BACKUPDIR2=$(echo $BACKUPDIR | sed 's/\//\\\//g')
#echo backupdir2:
#echo $BACKUPDIR2
MIDPART=$(echo $PWD | sed "s/$BACKUPDIR2//")
#echo midpart:
#echo $MIDPART

# figure out destination path
DESTDIR=$NASDIR/$MIDPART
echo destdir: $DESTDIR | tee -a $FILENAME

# set test flag for rsync
if [ $TESTRUN = true ] ; then
	TESTFLAG='-n'
else
	TESTFLAG=''
fi

# set move flag for rsync (as opposed to copy)
if [ $MOVEDATFILES = true ] ; then
	MOVEFLAG='--remove-source-files'
else
	MOVEFLAG=''
fi


# run rsync
/usr/bin/df | /usr/bin/grep $MOUNTSTRING # check if the NAS is mounted
if [ ${?} -eq 0 ] ; then
	# make empty copy of entire directory tree
	/usr/bin/rsync -v -a --progress \
	--include='*/' --exclude='*'  --no-perms --no-owner --stats \
        $BACKUPDIR $NASDIR | tee -a $FILENAME

	# use rsync to move .dat files
	rsync -vv $MOVEFLAG $TESTFLAG $SOURCEDIR/*.dat $DESTDIR | tee -a $FILENAME

else
	echo 
	echo ERROR - $MOUNTSTRING NOT FOUND! | tee -a $FILENAME
	echo
fi



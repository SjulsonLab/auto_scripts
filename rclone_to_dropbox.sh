#!/bin/bash

# Script to copy data from windows machine to dropbox
#
# Luke Sjulson, 2021-02-05

# clone the repo, then copy this file to your desktop and customize it.
# After customization, run it by opening git bash and typing
# ~/Desktop/rclone_to_dropbox.sh
# (you can probably double-click the icon on the desktop)
#
# if this script gives weird errors about "\r"'s, it is because the newlines are in windows
# format. Go to the git bash prompt and use sed (stream editor) as below to convert the windows
# newline characters to unix ones
# sed -i 's/\r$//' ~/Desktop/rclone_to_dropbox.sh

# update these as appropriate
# the directories have to be in the below format, with forward slashes (/), not backslashes (\)
# DESKTOP and SOURCEDIR must be enclosed in double-quotes, not single-quotes
# if there are any spaces in the directory names, you have to insert a \ before the space
DESKTOP="/c/Users/lab/Desktop"                  # desktop on windows - error messages are placed here
SOURCEDIR="/c/Users/lab/Desktop/Recordings\ 1"  # the windows directory containing the recording directories
RCLONE=$DESKTOP/auto_scripts/rclone.exe
TOEXCLUDE='*.jpg'                                    # original video files to exclude from rclone transfer
DESTINATION='luke_rclone'          					 # the destination directory on dropbox
# RCLONEPARAMS='--dry-run --progress'    # for debugging
RCLONEPARAMS='--progress'

echo $SOURCEDIR	
eval cd $SOURCEDIR

for BASENAME in */ ; do
	# echo "basename = " $BASENAME
	BASEDIR=$(echo $BASENAME | sed 's:/*$::')  # trims trailing slash
	# echo "basedir = " $BASEDIR
	BASEPATH="$SOURCEDIR/$BASEDIR" # for brevity
	# echo "basepath = " $BASEPATH
	LOGFILE="$BASEDIR/rclone_log.txt"
	echo "logfile = " $LOGFILE

	# check to see if this session has already been copied
	if eval test -f "$SOURCEDIR/$BASEDIR/session.copied"; then
		echo $BASEDIR has already been copied. Skipping!

	else # found a new session that hasn't already been copied
		pwd
		# TODO: insert ffmpeg commands to transcode the video here
		# cmd /C "ffmpeg.exe _______________________  "


		# use rclone to copy to rclone_to_dropbox
		echo "starting rclone at " `date` > $LOGFILE
		RCLONELINE=`echo $RCLONE copy --exclude $TOEXCLUDE $RCLONEPARAMS $BASEDIR dropbox:$DESTINATION/$BASEDIR | tee -a "$LOGFILE"`
 # 		echo $RCLONELINE  # for debugging
		eval $RCLONELINE

		# check if rclone worked properly, and if it did, put a session.copied file into $BASEDIR
		EXITCODE=$?  # $EXITCODE is zero if rclone worked
		if [ $EXITCODE -eq 0 ]; then
			echo "rclone completed successfully at " `date` | tee -a $LOGFILE
			echo "rclone completed successfully at " `date` > $BASEDIR/session.copied
			eval $RCLONELINE  # to copy session.copied to dropbox
		else
			echo "ERROR: rclone for " $BASEDIR " did not complete!!" | tee -a $LOGFILE
			eval touch "$DESKTOP/ERROR_$BASEDIR.txt" # puts a file on the desktop to let you know an error occurred
		fi
	fi
done


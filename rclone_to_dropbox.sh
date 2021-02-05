#!/bin/bash

# Script to copy data from windows machine to dropbox. You should save your customized version
# of this file on the desktop. To run this, open git bash and type
#
# cd ~/Desktop
# ./rclone_to_dropbox.sh

# if this script gives weird errors about "\r"'s, it is because the newlines are in windows
# format. Go to the git bash prompt and use sed (stream editor) as below to convert the windows
# newline characters to unix ones
# sed -i 's/\r$//' ~/Desktop/rclone_to_dropbox.sh

# update these as appropriate
DESKTOP="/c/Users/lab/Desktop"              # desktop on windows - error messages are placed here
SOURCEDIR="/c/Users/lab/Desktop/Recordings\ 1"  # the windows directory containing the recordings
RCLONE=$DESKTOP/auto_scripts/rclone.exe
TOEXCLUDE='*.jpg'                                    # original video files to exclude from rsync transfer
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

	if eval test -f "$SOURCEDIR/$BASEDIR/session.copied"; then
		echo $BASEDIR has already been copied. Skipping!
	else # found a new session that hasn't already been copied
		pwd
		# TODO: insert ffmpeg commands to transcode the video here
		# cmd /C "ffmpeg.exe _______________________  "


		# use rclone to copy to rclone_to_dropbox
		echo "starting rclone at " `date` > $LOGFILE
		# RCLONELINE=`echo $RCLONE copy --exclude $TOEXCLUDE $RCLONEPARAMS $BASEPATH dropbox:$DESTINATION/$BASEDIR | tee -a "$LOGFILE"`
		RCLONELINE=`echo $RCLONE copy --exclude $TOEXCLUDE $RCLONEPARAMS $BASEDIR dropbox:$DESTINATION/$BASEDIR | tee -a "$LOGFILE"`
		# echo $RCLONELINE

# # 		echo $RCLONELINE  # for debugging
		$RCLONELINE
		EXITCODE=$?  # zero if the rclone worked
		if [ $EXITCODE -eq 0 ]; then
			echo "rclone completed successfully at " `date` | tee -a $LOGFILE
			echo "rclone completed successfully at " `date` > $BASEDIR/session.copied
			$RCLONELINE  # to copy session.copied over
		else
			echo "ERROR: rclone for " $BASEDIR " did not complete!!" | tee -a $LOGFILE
			eval touch "$DESKTOP/ERROR_$BASEDIR.txt"
		fi
	fi
done


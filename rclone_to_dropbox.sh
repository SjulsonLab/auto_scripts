#!/bin/bash

# Script to copy data from windows machine to Linux box. To run this, open cygwin and type
# copy_to_workstation

# if this script gives weird errors about "\r"'s, it is because the newlines are in windows
# format. Go to the cygwin prompt and use sed (stream editor) as below to convert the windows
# newline characters to unix ones

# sed -i 's/\r$//' rclone_to_dropbox.sh

# update these as appropriate
DESKTOP='/cygdrive/c/Users/lab/Desktop'              # desktop on windows - error messages are placed here
SOURCEDIR='/cygdrive/c/Users/lab/Desktop/Recordings' # the windows directory containing the recordings
TOEXCLUDE='*.jpg'                                    # original video files to exclude from rsync transfer
DESTINATION='luke_rclone'          					 # the destination directory on dropbox


cd $SOURCEDIR
for basename in */ ; do
	basedir=$(echo $basename | sed 's:/*$::')  # trims trailing slash
	if test -f "$SOURCEDIR/$basedir/session.copied"; then
		echo $basedir has already been copied. Skipping!
	else # found a new session that hasn't already been copied

		# TODO: insert ffmpeg commands to transcode the video here
		# cmd /C "ffmpeg.exe _______________________  "


		# use rclone to copy to dropbox
		$DESKTOP/auto_scripts/rclone.exe

		# use rsync to copy to the Linux box
		# this excludes the original, pre-transcoded video files

#		rsync -av --exclude $TOEXCLUDE --progress $SOURCEDIR/$basedir $DESTINATION | tee -a $basedir/rsync_log.txt

		# if [ $? -eq 0 ]; then  # if rsync executed successfully
		# 	echo copied successfully: `date` | tee -a $SOURCEDIR/$basedir/session.copied
		# 	rsync $SOURCEDIR/$basedir/rsync_log.txt $DESTINATION/$basedir  # copy these files over to let the 
		# 	rsync $SOURCEDIR/$basedir/session.copied $DESTINATION/$basedir # workstation know the rsync is finished
		# else # if rsync encountered an error
		# 	echo ERROR!!!
		# 	touch $DESKTOP/ERROR_$basedir.txt
		# fi
	fi
done


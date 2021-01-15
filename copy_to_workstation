#!/bin/bash

# Script to copy data from windows machine to Linux box. To run this, open cygwin and type
# copy_to_workstation

# if this script gives weird errors about "\r"'s, it is because the newlines are in windows
# format. Go to the cygwin prompt and use sed (stream editor) as below to convert the windows
# newline characters to unix ones

# sed -i 's/\r$//' copy_to_workstation

# update these as appropriate
DESKTOP='/cygdrive/c/Users/lab/Desktop'              # desktop on windows - error messages are placed here
SOURCEDIR='/cygdrive/c/Users/lab/Desktop/Recordings' # the windows directory containing the recordings
TOEXCLUDE='*.jpg'                                    # original video files to exclude from rsync transfer
DESTINATION='luke@10.49.150.110:temp'                # the destination directory on the linux box

####### Note: first try "ssh luke@10.49.150.110" (or equivalent). If you can't log in at all, there's a network problem.
####### If you can log in but need a password, send an SSH key. First, go to the cygwin prompt:
# ssh-keygen -t rsa
####### (If it asks you to overwrite the old key, say no because you already have one. Otherwise, hit enter to all,
####### and don't use a passphrase)
# ssh-copy-id luke@10.49.150.110
####### That copies your key to the linux box. After that, you should be able to log in with ssh (and rsync) without a password


cd $SOURCEDIR
for basename in */ ; do
	basedir=$(echo $basename | sed 's:/*$::')  # trims trailing slash
	if test -f "$SOURCEDIR/$basedir/session.copied"; then
		echo $basedir has already been copied. Skipping!
	else # found a new session that hasn't already been copied

		# TODO: insert ffmpeg commands to transcode the video here
		# cmd /C "ffmpeg.exe _______________________  "

		# use rsync to copy to the Linux box
		# this excludes the original, pre-transcoded video files
		rsync -av --exclude $TOEXCLUDE --progress $SOURCEDIR/$basedir $DESTINATION | tee -a $basedir/rsync_log.txt

		if [ $? -eq 0 ]; then  # if rsync executed successfully
			echo copied successfully: `date` | tee -a $SOURCEDIR/$basedir/session.copied
			rsync $SOURCEDIR/$basedir/rsync_log.txt $DESTINATION/$basedir  # copy these files over to let the 
			rsync $SOURCEDIR/$basedir/session.copied $DESTINATION/$basedir # workstation know the rsync is finished
		else # if rsync encountered an error
			echo ERROR!!!
			touch $DESKTOP/ERROR_$basedir.txt
		fi
	fi
done


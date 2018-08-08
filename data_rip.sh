#!/bin/bash
# Rip Data using DD

# shellcheck disable=SC1091
# shellcheck source=config
source "$ARM_CONFIG"
# shellcheck disable=SC1090
source "$DISC_INFO"

LOG=$1

{

        TIMESTAMP=$(date '+%Y%m%d_%H%M%S');
        DEST="${DATACD_DIR}/${TIMESTAMP}_${ID_FS_LABEL}"
        mkdir -p "$DEST"
	FILENAMEBIN=${ID_FS_LABEL}_disc.bin
	FILENAMETOC=${ID_FS_LABEL}_disc.toc
	FILENAMECUE=${ID_FS_LABEL}_disc.cue
	FILENAME7Z=${ID_FS_LABEL}_disc.7z


	#dd if=/dev/sr0 of=$DEST/$FILENAME
	#cat "$DEVNAME" > "$DEST/$FILENAME"
	cdrdao read-cd --datafile "$DEST/$FILENAMEBIN" --driver generic-mmc:0x20000 --device "$DEVNAME" --read-raw "$DEST/$FILENAMETOC"
	toc2cue "$DEST/$FILENAMETOC" "$DEST/$FILENAMECUE"
	7z a "$DEST/$FILENAME7Z" "$DEST/$FILENAMEBIN" "$DEST/$FILENAMECUE"
	rm "$DEST/$FILENAMEBIN"
	rm "$DEST/$FILENAMETOC"
	rm "$DEST/$FILENAMECUE"
	

	if [ "$SET_MEDIA_PERMISSIONS" = true ]; then

	chmod -R "$CHMOD_VALUE" "$DEST"

	fi

	if [ "$SET_MEDIA_OWNER" = true ]; then

	chown -R "$CHOWN_USER":"$CHOWN_GROUP" "$DEST"

	fi

	if [ "$NOTIFY_RIP" = "true" ]; then
		echo /opt/arm/notify.sh "\"Ripped: ${FILENAME} completed from ${DEVNAME}\" \"$LOG\""|at -M now
    fi

} >> "$LOG"

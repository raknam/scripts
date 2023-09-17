#!/bin/bash

# Script to automagically update Plex Media Server on Synology NAS
#
# Must be run as root.
#
# @author @martinorob https://github.com/martinorob
# https://github.com/martinorob/plexupdate/

PLEX_PKG_NAME=PlexMediaServer

mkdir -p /tmp/plex/ > /dev/null 2>&1
PLEX_TOKEN=$(cat /volume4/PlexMediaServer/AppData/Plex\ Media\ Server/Preferences.xml | grep -oP 'PlexOnlineToken="\K[^"]+')
PLEX_URL=$(echo "https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=$PLEX_TOKEN")
PLEX_JSON=$(curl -s "$PLEX_URL")
PLEX_NEW_VER=$(echo "$PLEX_JSON" | jq -r .nas.Synology.version | awk -F- '{print $1}')
echo "New Ver: $PLEX_NEW_VER"
PLEX_CUR_VER=$(synopkg version $PLEX_PKG_NAME| awk -F- '{print $1}')
echo "Cur Ver: $PLEX_CUR_VER"
if [ "$PLEX_NEW_VER" != "$PLEX_CUR_VER" ]
then
	echo "New Version Available"
	PLEX_CPU=$(uname -m)
	PLEX_PKG_URL=$(echo "$PLEX_JSON" | jq -r '.nas."Synology (DSM 7)".releases[] | select(.build=="linux-'"$PLEX_CPU"'") | .url')
	/bin/wget -q $PLEX_PKG_URL -P /tmp/plex/
	/usr/syno/bin/synopkg install /tmp/plex/*.spk
	sleep 30
	/usr/syno/bin/synopkg start $PLEX_PKG_NAME
	rm -rf /tmp/plex/*
else
	echo "No New Version"
fi
exit

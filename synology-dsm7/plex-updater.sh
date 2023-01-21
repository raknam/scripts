#!/bin/bash

# Script to automagically update Plex Media Server on Synology NAS
#
# Must be run as root.
#
# @author @martinorob https://github.com/martinorob
# https://github.com/martinorob/plexupdate/

PKG_NAME=PlexMediaServer

mkdir -p /tmp/plex/ > /dev/null 2>&1
token=$(cat /volume1/PlexMediaServer/AppData/Plex\ Media\ Server/Preferences.xml | grep -oP 'PlexOnlineToken="\K[^"]+')
url=$(echo "https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=$token")
jq=$(curl -s ${url})
newversion=$(echo $jq | jq -r .nas.Synology.version | awk -F- '{print $1}')
echo New Ver: $newversion
curversion=$(synopkg version $PKG_NAME | awk -F- '{print $1}')
echo Cur Ver: $curversion
if [ "$newversion" != "$curversion" ]
then
	echo New Vers Available
	/usr/syno/bin/synonotify PKGHasUpgrade '{"[%HOSTNAME%]": $(hostname), "[%OSNAME%]": "Synology", "[%PKG_HAS_UPDATE%]": "Plex", "[%COMPANY_NAME%]": "Synology"}'
	CPU=$(uname -m)
	url=$(echo "${jq}" | jq -r '.nas."Synology (DSM 7)".releases[] | select(.build=="linux-'"${CPU}"'") | .url')
	/bin/wget -q $url -P /tmp/plex/
	/usr/syno/bin/synopkg install /tmp/plex/*.spk
	sleep 30
	/usr/syno/bin/synopkg start $PKG_NAME
	rm -rf /tmp/plex/*
else
	echo No New Ver
fi
exit
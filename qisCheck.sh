#!/bin/bash

md5File="${XDG_CACHE_HOME}/qis.md5"
cookieJar="/tmp/qis.cookiejar"

STUDY_COURSE="${STUDY_COURSE:-INB}" # Or INM, …
TELEGRAM_SEND_FILE="${TELEGRAM_SEND_FILE:-false}"

if [[ -z "$TELEGRAM_TOKEN" ]] || [[ -z "$TELEGRAM_CHAT_ID" ]] || [[ -z "$HTWK_SHIBBOLETH_USERNAME" ]] || [[ -z "$HTWK_SHIBBOLETH_PASSWORD" ]]; then
	echo "Required ENV variables:"
	echo "* TELEGRAM_TOKEN"
	echo "* TELEGRAM_CHAT_ID"
	echo "* HTWK_SHIBBOLETH_USERNAME"
	echo "* HTWK_SHIBBOLETH_PASSWORD"
	echo ""
	echo "Optional ENV variables:"
	echo "* STUDY_COURSE"
	echo "* TELEGRAM_SEND_FILE"
	exit 2
fi

function telegramFile {
	curl -s -F chat_id="$TELEGRAM_CHAT_ID" -F document=@"$1" "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" > /dev/null
}

function telegramMsg {
	curl -s --data-urlencode "text=$1" --data-urlencode "parse_mode=Markdown" "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage?chat_id=${TELEGRAM_CHAT_ID}" > /dev/null
}

shred -u "$cookieJar" 2>/dev/null

asi="$(curl -s -D - 'https://qisserver.htwk-leipzig.de/qisserver/rds?state=user&type=1&category=auth.login&startpage=portal.vm&topitem=functions&breadCrumbSource=portal' --data "username=${HTWK_SHIBBOLETH_USERNAME}&password=${HTWK_SHIBBOLETH_PASSWORD}&submit=Anmelden" -b "$cookieJar" -c "$cookieJar" | grep -oP "(?<=asi=)\w+")"

if [[ "$(echo -n "$asi" | wc -c)" -lt 5 ]]; then
	echo "ASI too short: $asi"
	exit 1
fi

echo "Found ASI: $asi"

qisContent="$(curl -s "https://qisserver.htwk-leipzig.de/qisserver/rds?state=notenspiegelStudent&next=list.vm&nextdir=qispos/notenspiegel/student&menuid=notenspiegelStudent&createInfos=Y&struct=auswahlBaum&nodeID=auswahlBaum|abschluss%3Aabschl%3D90%2Cstgnr%3D1|studiengang%3Astg%3D${STUDY_COURSE}&expand=0" -b "$cookieJar" -c "$cookieJar" -G --data-urlencode "asi=${asi}")"

rm -f "$cookieJar" 2>/dev/null

match="$(echo -n "$qisContent" | tr -d '\n' | tr -d '\r' | sed -ne 's/.*<table class="recordTable">\(.*\)<\/table>.*/\1/p' | sed "s/${asi}//g" | sed 's/[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{4\}//g')"

if [ -n "$match" ] && echo "$match" | grep -q "1. Semester"; then
	matchMD5="$(echo -n "$match" | md5sum | cut -d\  -f1)"
	echo "Got MD5: $matchMD5"
	if [ -f "$md5File" ]; then
		md5FileContent="$(cat "$md5File")"
		if [ "$md5FileContent" != "$matchMD5" ]; then

			#echo -n "$qisContent" > "${XDG_CACHE_HOME}/debug1_$(date -Is).html"
			#echo -n "$match" > "${XDG_CACHE_HOME}/debug2_$(date -Is).html"

			echo "New MD5, sending messages."
			telegramMsg "Possible QIS Update! $md5FileContent vs $matchMD5!"
			if [[ "$TELEGRAM_SEND_FILE" = true ]]; then
				qisFile="/tmp/qis.html"
				echo -n "$qisContent" > "$qisFile"
				telegramFile "$qisFile"
				shred -u "$qisFile"
			fi
		else
			echo "No new MD5."
		fi
	fi
	echo -n "$matchMD5" > "$md5File"
else
	echo "Failed to read the QIS table."
	#telegramMsg "Possible failure: Failed to read the QIS table."
	exit 1
fi

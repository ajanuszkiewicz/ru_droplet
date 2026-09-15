-- ruTorrent Droplet
-- Drop .torrent files on this app (in your Dock) to upload them to a ruTorrent server.
--
-- Setup (see README.md for full details):
--   1. Store your password in Keychain:
--      security add-generic-password -a "<username>" -s "rutorrent-droplet" -w "<password>" -U
--   2. Create ~/.config/rutorrent-droplet/config with:
--      SERVER_URL=https://your-server/rutorrent/php/addtorrent.php
--      KEYCHAIN_ACCOUNT=<username>
--      KEYCHAIN_SERVICE=rutorrent-droplet
--   3. Build: osacompile -o "ruTorrent Droplet.app" rutorrent_droplet.applescript

property configPath : "~/.config/rutorrent-droplet/config"

on open theFiles
	set configValues to readConfig()
	set serverURL to configValue(configValues, "SERVER_URL")
	set keychainAccount to configValue(configValues, "KEYCHAIN_ACCOUNT")
	set keychainService to configValue(configValues, "KEYCHAIN_SERVICE")

	if serverURL is "" or keychainAccount is "" or keychainService is "" then
		display notification "Missing config at " & configPath with title "ruTorrent Droplet"
		return
	end if

	set thePassword to do shell script "security find-generic-password -a " & quoted form of keychainAccount & " -s " & quoted form of keychainService & " -w"

	set successNames to {}
	set failNames to {}

	repeat with anItem in theFiles
		set thePath to POSIX path of anItem
		set isTorrent to false
		ignoring case
			if thePath ends with ".torrent" then set isTorrent to true
		end ignoring

		if isTorrent then
			set fileName to do shell script "basename " & quoted form of thePath
			set headerFile to "/tmp/rutorrent_droplet_headers_" & (random number from 100000 to 999999) & ".txt"
			set curlCmd to "curl -s -S -D " & quoted form of headerFile & " -o /dev/null -w '%{http_code}' -u " & quoted form of (keychainAccount & ":" & thePassword) & " -F " & quoted form of ("torrent_file[]=@" & thePath) & " " & quoted form of serverURL
			try
				set httpCode to do shell script curlCmd
				set headerContent to ""
				try
					set headerContent to do shell script "cat " & quoted form of headerFile
				end try
				do shell script "rm -f " & quoted form of headerFile

				if httpCode is "401" then
					set end of failNames to (fileName & " (auth failed)")
				else if headerContent contains "FailedFile" then
					set end of failNames to (fileName & " (rejected by server)")
				else if httpCode starts with "2" or httpCode starts with "3" then
					set end of successNames to fileName
				else
					set end of failNames to (fileName & " (HTTP " & httpCode & ")")
				end if
			on error errMsg
				set end of failNames to (fileName & " (" & errMsg & ")")
			end try
		end if
	end repeat

	if (count of successNames) > 0 and (count of failNames) is 0 then
		display notification ((count of successNames) as text) & " torrent(s) added" with title "ruTorrent Droplet"
	else if (count of successNames) > 0 and (count of failNames) > 0 then
		display notification ((count of successNames) as text) & " added, " & ((count of failNames) as text) & " failed" with title "ruTorrent Droplet" subtitle (my joinList(failNames, ", "))
	else if (count of failNames) > 0 then
		display notification "Failed: " & my joinList(failNames, ", ") with title "ruTorrent Droplet"
	else
		display notification "No .torrent files were dropped" with title "ruTorrent Droplet"
	end if
end open

on readConfig()
	try
		set fileText to do shell script "cat " & configPath
	on error
		return {}
	end try
	set theLines to paragraphs of fileText
	set theConfig to {}
	repeat with aLine in theLines
		set aLine to aLine as text
		if aLine contains "=" and aLine does not start with "#" then
			set AppleScript's text item delimiters to "="
			set lineParts to text items of aLine
			set AppleScript's text item delimiters to ""
			set theKey to item 1 of lineParts
			set theValue to (items 2 thru -1 of lineParts) as text
			set end of theConfig to {key:theKey, value:theValue}
		end if
	end repeat
	return theConfig
end readConfig

on configValue(theConfig, theKey)
	repeat with anEntry in theConfig
		if (key of anEntry) is theKey then return (value of anEntry)
	end repeat
	return ""
end configValue

on joinList(theList, theDelim)
	set AppleScript's text item delimiters to theDelim
	set theText to theList as text
	set AppleScript's text item delimiters to ""
	return theText
end joinList

#!/usr/bin/env python

import sys, re, json

## 1. Delete appinfo.vdf if it exists (where is this? in cache dir?)

## Load the sample file (DEBUGGING ONLY)
try:
	file = open("sample.txt", "r")
except IOError:
	print "There was an error reading file"
	sys.exit()
file_text = file.read()
file.close()

## Parse the branch specific (DEBUG NOTE: public is used in this case)
file_text = "\t{\n" + file_text + "\t}"
file_text = file_text.replace('"\t\t"', '":\t\t"')
file_text = file_text.replace("\t", "").replace("\n", "")
file_text = file_text.replace('""', '","')
file_text = file_text.replace('"{"', '":{"')
#print file_text

## Convert the result to a JSON object
try:
	json_object = json.loads(file_text)
except ValueError, e:
	print "There was an error parsing the JSON:", e
	sys.exit()

## Get both the latest build id and the time it was updated
build_id = json_object['public']['buildid']
time_updated = json_object['public']['timeupdated']
#print "Build id for branch public is: " + build_id + "(time updated: " + time_updated + ")"

## Write build id to file
try:
	buildid_latest = open("buildid_latest", "w")
except IOError:
	print "There was an error reading file"
	sys.exit()

## 3. Compare current file and new file, if they don't match restart the server with a timer to force an update
## 4. Delete new file (optionaly really)

## TODO: Use websockets to send the restart command (with a specific time interval? say 60 seconds?)

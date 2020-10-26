#!/bin/bash

timestamp=$(date +"%s")
week=$(date +"%U")
month=$(date +"%m")

# create folders if necessary
mkdir /home/steff/arabaucam/dl
mkdir /home/steff/arabaucam/dl/w$week
mkdir /home/steff/arabaucam/dl/m$month

# download image
wget -c https://www.pool-informatik.ch/cams/cam1805.jpg -O /home/steff/arabaucam/dl/w$week/$timestamp.jpg

# check if image is bright enough
luma=$(convert /home/steff/arabaucam/dl/w$week/$timestamp.jpg -colorspace Gray -format "%[fx:quantumrange*image.mean]" info:)
luma=$( printf "%.0f" $luma )

echo "Brightness: "
echo $luma

if((luma < 20000)); then
	# delete image if too dark
	rm /home/steff/arabaucam/dl/w$week/$timestamp.jpg
else
	# if image is bright enough, copy it to the month folder
	cp /home/steff/arabaucam/dl/w$week/$timestamp.jpg /home/steff/arabaucam/dl/m$month/$timestamp.jpg
fi


# delete old files
find /home/steff/arabaucam/dl -mtime +45 -type f -name '*.jpg' -delete

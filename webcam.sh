#!/bin/bash

timestamp=$(date +"%s")
week=$(date +"%U")
month=$(date +"%m")
day=$(date +"%d")
weekday=$(date +"%u")
dayFull="${day}_${weekday}"

# create folders if necessary
mkdir -p /home/steff/arabaucam/dl/m$month/w$week/d$dayFull

# download image
wget -c https://www.pool-informatik.ch/cams/cam1805.jpg -O /home/steff/arabaucam/dl/m$month/w$week/d$dayFull/$timestamp.jpg

# check if image is bright enough
luma=$(convert /home/steff/arabaucam/dl/m$month/w$week/d$dayFull/$timestamp.jpg -colorspace Gray -format "%[fx:quantumrange*image.mean]" info:)
luma=$( printf "%.0f" $luma )

echo "Brightness: "
echo $luma

if((luma < 20000)); then
	# delete image if too dark
	rm /home/steff/arabaucam/dl/m$month/w$week/d$dayFull/$timestamp.jpg
fi


# delete old files
find /home/steff/arabaucam/dl -mtime +45 -type f -name '*.jpg' -delete

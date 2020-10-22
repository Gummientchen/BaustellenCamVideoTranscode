# Copy all the Weekly Iamges into the weekly folder, then execute this script.
# Delete unwanted images before you start this script

$i = 0

Set-Location weekly
Get-ChildItem *.jpg | %{Rename-Item $_ -NewName ('{0:D5}.jpg' -f $i++)}

..\ffmpeg.exe -r 60 -f image2 -s 1920x1080 -i %05d.jpg -vcodec libx264 -crf 18 -vf scale=3840:2160:flags=lanczos,tpad=stop_duration=20 -pix_fmt yuv420p ..\output\week.mp4

pause
# Copy all the Monthly Iamges into the monthly folder, then execute this script.
# Delete unwanted images before you start this script

$i = 0

Set-Location monthly
Get-ChildItem *.jpg | %{Rename-Item $_ -NewName ('{0:D5}.jpg' -f $i++)}

..\ffmpeg.exe -r 25 -f image2 -s 1920x1080 -i %05d.jpg -vcodec libx264 -crf 20 -vf "setpts=(1/5)*PTS,scale=3840:2160:flags=lanczos" -pix_fmt yuv420p ..\output\monthtmp.mp4
..\ffmpeg.exe -i ..\output\monthtmp.mp4 -i ..\yt_ending_screen.mp4 -c:v libx264 -preset veryfast -profile:v high -crf 20 -vsync 2 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -filter_complex "[0:v] [1:v] concat=n=2:v=1 [v]" -map "[v]" ..\output\month.mp4

Remove-Item ..\output\monthtmp.mp4

pause
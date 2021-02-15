# Copy all the Yearly Iamges into the weekly folder, then execute this script.
# Delete unwanted images before you start this script

$i = 0

Set-Location yearly
$targetDir = Convert-Path '.' # Get the current (target) directory's full path.
Get-ChildItem -Path $targetDir -Recurse -Filter "*.jpg" | Move-Item -destination $targetDir

Get-ChildItem *.jpg | %{Rename-Item $_ -NewName ('{0:D5}.jpg' -f $i++)}

..\ffmpeg.exe -r 30 -f image2 -s 1920x1080 -i %05d.jpg -vcodec libx264 -crf 20 -vf "setpts=(5)*PTS,scale=3840:2160:flags=lanczos" -pix_fmt yuv420p ..\output\yeartmp.mp4
..\ffmpeg.exe -i ..\output\yeartmp.mp4 -i ..\yt_ending_screen.mp4 -c:v libx264 -preset veryfast -profile:v high -crf 20 -vsync 2 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -filter_complex "[0:v] [1:v] concat=n=2:v=1 [v]" -map "[v]" ..\output\year.mp4

Remove-Item ..\output\yeartmp.mp4

pause
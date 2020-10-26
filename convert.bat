echo off

"%~dp0ffmpeg.exe" -i "%~1" -c:v libx264 -preset veryfast -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -vf setpts=5*PTS,scale=3840:2160:flags=lanczos "%~dp0\timelapse.mp4"
"%~dp0ffmpeg.exe" -i "%~dp0timelapse.mp4" -i "%~dp0yt_ending_screen.mp4" -c:v libx264 -preset veryfast -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -filter_complex "[0:v] [1:v] concat=n=2:v=1 [v]" -map "[v]" "%~1"_recoded.mp4

del "%~dp0\timelapse.mp4"

pause
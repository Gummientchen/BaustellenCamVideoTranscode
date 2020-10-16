echo off
"%~dp0ffmpeg.exe" -i "%~1" -c:v libx264 -preset veryfast -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -vf setpts=8*PTS,scale=3840:2160:flags=lanczos "%~1"_recoded.mp4
rem "%~dp0ffmpeg.exe" -i "%~1" -c:v libx264 -preset fast -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 384k -profile:a aac_low -vf setsar_sar=0 -vf setdar=dar=0 -vf scale=3840:2160:flags=lanczos "%~1"_recoded.mp4


pause
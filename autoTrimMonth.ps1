Clear-Host;

$fps = 25;
$defaultStartTime = 7.5;
$defaultEndTime = 17.5;
$defaultImageInterval = 5;


Write-Host "-----------------------------------------------------";
Write-Host "|                                                   |";
Write-Host "|     Ara Neubau Baustellencam Video Converter      |";
Write-Host "|                                                   |";
Write-Host "-----------------------------------------------------";
Write-Host "Dieses Script entfernt automatisch Wochenenden aus";
Write-Host "einem Timelapse Video.";
Write-Host "";
Write-Host "";
Write-Host "";
pause

function getDayInfo{
    param (
        $offset,
        $duration,
        $date
    )

    [hashtable]$return = @{}

    $return.weekday = $date.DayOfWeek.value__;
    $return.startFrame = $offset+1;
    $return.endFrame = $offset + $duration;

    return $return;
}

# open file dialog for the user to choose a video file
Add-Type -AssemblyName System.Windows.Forms;
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = 'MPEG4 (*.mp4)|*.mp4'
}
$null = $FileBrowser.ShowDialog();

$inputFile = $FileBrowser.FileName;
$scriptDir = Split-Path $script:MyInvocation.MyCommand.Path;


$currentDate = Get-Date;

# Ask user for start and end date + times + image interval
Write-Host "Bitte gib die benötigten Informationen für das Monatsvideo ein.";
Write-Host ""
Write-Host "-----------------------------------------------------";
Write-Host "Video Start Date";

# Start Date
$yearStart = Read-Host -Prompt "Start Year [$($currentDate.get_Year())]";
if ([string]::IsNullOrWhiteSpace($yearStart)){ $yearStart = $currentDate.get_Year() }

$monthStart = Read-Host -Prompt "Start Month [$($currentDate.get_Month()-1)]";
if ([string]::IsNullOrWhiteSpace($monthStart)){ $monthStart = $currentDate.get_Month()-1 }

$dayStart = Read-Host -Prompt "Start Day [1]";
if ([string]::IsNullOrWhiteSpace($dayStart)){ $dayStart = 1 }

Write-Host "";
Write-Host "-----------------------------------------------------";
Write-Host "Video End Date";

# End Date
$yearEnd = Read-Host -Prompt "End Year [$($currentDate.get_Year())]";
if ([string]::IsNullOrWhiteSpace($yearEnd)){ $yearEnd = $currentDate.get_Year() }

$monthEnd = Read-Host -Prompt "End Month [$($currentDate.get_Month()-1)]";
if ([string]::IsNullOrWhiteSpace($monthEnd)){ $monthEnd = $currentDate.get_Month()-1 }

$dayEnd = Read-Host -Prompt "End Day [$([DateTime]::DaysInMonth($yearEnd, $monthEnd))]";
if ([string]::IsNullOrWhiteSpace($dayEnd)){ $dayEnd = [DateTime]::DaysInMonth($yearEnd, $monthEnd) }

Write-Host "";
Write-Host "-----------------------------------------------------";
Write-Host "Start Time in decimal: 07:30 => 7.5";

# Start Time
$timeStart = Read-Host -Prompt "Start Time [$($defaultStartTime)]";
if ([string]::IsNullOrWhiteSpace($timeStart)){ $timeStart = $defaultStartTime }

$timeEnd = Read-Host -Prompt "End Time [$($defaultEndTime)]";
if ([string]::IsNullOrWhiteSpace($timeEnd)){ $timeEnd = $defaultEndTime }

Write-Host "";
Write-Host "-----------------------------------------------------";
Write-Host "Image Interval 5,15,30,60,120,1440";

# Image Interval
$imageInterval = Read-Host -Prompt "Image Interval [$($defaultImageInterval)]";
if ([string]::IsNullOrWhiteSpace($imageInterval)){ $imageInterval = $defaultImageInterval }



# calculate how many frames a single day has
$framesPerDay = ($timeEnd - $timeStart) * (60 / $imageInterval);
$globalOffset = 0;

# define ffmpeg commands
$ffmpegExe = ($scriptDir + '\ffmpeg.exe');
$ffmpegCommand = (' -i "' + $inputFile + '"');
$ffmpegCommand = ($ffmpegCommand + ' -vf "select=');

$ffmpegSelect = @();

# iterate over all days to determine of it is a weekend and if not get the start and end timestamps
For ($i=$dayStart; $i -le $dayEnd; $i++) {
    
    $checkDate = Get-Date -Year $yearStart -Month $monthStart -Day $i;
    $dayInfo = getDayInfo -offset $globalOffset -duration $framesPerDay -date $checkDate;

    $globalOffset = $dayInfo.endFrame;

    if($dayInfo.weekday -gt 0 -And $dayInfo.weekday -lt 6){
        $startFrame = $dayInfo.startFrame;
        $endFrame = $dayInfo.endFrame;

        $command = "between(n,$($startFrame),$($endFrame))";

        $ffmpegSelect += ,$command;
    }

}

# Create Output Filename for ffmpeg
$inputFileObject = Get-Item $inputFile;
$outputFileName = ($inputFileObject.Basename + "_recoded.mp4");
$outputPath = $inputFileObject.DirectoryName;
$outputFilenameAndPath = $outputPath + "\" + $outputFileName;

# Create ffmpeg command
$ffmpegSelectCommand = $ffmpegSelect -join '+';
$ffmpegSelectCommand = ("'" + $ffmpegSelectCommand + "',setpts=N/FRAME_RATE/TB, scale=3840:2160:flags=lanczos" + '" ');
$ffmpegCommand = ($ffmpegCommand + $ffmpegSelectCommand);
$ffmpegCommand = ($ffmpegCommand + "-c:v libx264 -preset veryfast -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 " + '"' + $outputFilenameAndPath + '"');
$ffmpegFullCommand = ('"' + $ffmpegExe + '" ' + $ffmpegCommand);

# define temporary batch file path and name
$ffmpegBatchFile = ($scriptDir + "\trimVideo.bat");

Write-Host ('"' + $ffmpegExe + '" ' + $ffmpegCommand);

# create temporay batch file for ffmpeg
[IO.File]::WriteAllLines($ffmpegBatchFile, $ffmpegFullCommand);

# execute temporary batch file for ffmpeg
cmd.exe /c $ffmpegBatchFile

# delete temporary batch file
Remove-Item $ffmpegBatchFile;
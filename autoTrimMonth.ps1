Clear-Host

$fps = 25;
$defaultStartTime = 7.5;
$defaultEndTime = 17.5;

function getDayInfo{
    param (
        $offset,
        $duration,
        $date
    )

    [hashtable]$return = @{}

    $return.weekday = $date.DayOfWeek.value__;
    $return.startFrame = $offset;
    $return.endFrame = $offset + $duration;

    return $return;
}

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = 'MPEG4 (*.mp4)|*.mp4'
}
$null = $FileBrowser.ShowDialog()

$inputFile = $FileBrowser.FileName;
$scriptDir = Split-Path $script:MyInvocation.MyCommand.Path;


$currentDate = Get-Date;

# Ask user for start and end date + times
Write-Host "Bitte gib die benötigten Informationen für das Monatsvideo ein."
Write-Host ""
Write-Host "-----------------------------------------------------"
Write-Host "Video Start Date"

# Start Date
$yearStart = Read-Host -Prompt "Start Year [$($currentDate.get_Year())]"
if ([string]::IsNullOrWhiteSpace($yearStart)){ $yearStart = $currentDate.get_Year() }

$monthStart = Read-Host -Prompt "Start Month [$($currentDate.get_Month()-1)]"
if ([string]::IsNullOrWhiteSpace($monthStart)){ $monthStart = $currentDate.get_Month()-1 }

$dayStart = Read-Host -Prompt "Start Day [1]"
if ([string]::IsNullOrWhiteSpace($dayStart)){ $dayStart = 1 }

Write-Host ""
Write-Host "-----------------------------------------------------"
Write-Host "Video End Date"

# End Date
$yearEnd = Read-Host -Prompt "End Year [$($currentDate.get_Year())]"
if ([string]::IsNullOrWhiteSpace($yearEnd)){ $yearEnd = $currentDate.get_Year() }

$monthEnd = Read-Host -Prompt "End Month [$($currentDate.get_Month()-1)]"
if ([string]::IsNullOrWhiteSpace($monthEnd)){ $monthEnd = $currentDate.get_Month()-1 }

$dayEnd = Read-Host -Prompt "End Day [$([DateTime]::DaysInMonth($yearEnd, $monthEnd))]"
if ([string]::IsNullOrWhiteSpace($dayEnd)){ $dayEnd = [DateTime]::DaysInMonth($yearEnd, $monthEnd) }

Write-Host ""
Write-Host "-----------------------------------------------------"
Write-Host "Start Time in decimal: 07:30 => 7.5"

# Start Time
$timeStart = Read-Host -Prompt "Start Time [7.5]"
if ([string]::IsNullOrWhiteSpace($timeStart)){ $timeStart = $defaultStartTime }

$timeEnd = Read-Host -Prompt "End Time [17.5]"
if ([string]::IsNullOrWhiteSpace($timeEnd)){ $timeEnd = $defaultEndTime }


Write-Host ""
Write-Host "-----------------------------------------------------"

Write-Host "Start:"
Write-Host $yearStart
Write-Host $monthStart
Write-Host $dayStart

Write-Host "-------------------------------"
Write-Host "End:"
Write-Host $yearEnd
Write-Host $monthEnd
Write-Host $dayEnd

Write-Host "-------------------------------"
Write-Host "Times:"
Write-Host $timeStart
Write-Host $timeEnd

$framesPerDay = ($timeEnd - $timeStart) * 12
$globalOffset = 0;

$ffmpegExe = ($scriptDir + '\ffmpeg.exe');
$ffmpegCommand = (' -i "' + $inputFile + '"');
$ffmpegCommand = ($ffmpegCommand + ' -vf "select=');

$ffmpegSelect = @();

For ($i=$dayStart; $i -le $dayEnd; $i++) {
    
    $checkDate = Get-Date -Year $yearStart -Month $monthStart -Day $i
    $dayInfo = getDayInfo -offset $globalOffset -duration $framesPerDay -date $checkDate;

    $globalOffset = $dayInfo.endFrame;

    if($dayInfo.weekday -gt 0 -And $dayInfo.weekday -lt 6){
        $startSeconds = ($dayInfo.startFrame + 1) / $fps;
        $endSeconds = ($dayInfo.endFrame - 1) / $fps;

        $command = "between(t,$($startSeconds),$($endSeconds))";

        $ffmpegSelect += ,$command;
    }

}

$ffmpegSelectCommand = $ffmpegSelect -join '+';
$ffmpegSelectCommand = ("'" + $ffmpegSelectCommand + "',setpts=N/FRAME_RATE/TB, scale=3840:2160:flags=lanczos" + '" ');
$ffmpegCommand = ($ffmpegCommand + $ffmpegSelectCommand);
$ffmpegCommand = ($ffmpegCommand + "-c:v libx264 -preset veryfast -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 384k -profile:a aac_low " + $inputFile + "_recoded.mp4")
$ffmpegFullCommand = ('"' + $ffmpegExe + '" ' + $ffmpegCommand);
$ffmpegBatchFile = ($scriptDir + "\trimVideo.bat");

Write-Host ('"' + $ffmpegExe + '" ' + $ffmpegCommand);

[IO.File]::WriteAllLines($ffmpegBatchFile, $ffmpegFullCommand);

cmd.exe /c $ffmpegBatchFile

Remove-Item $ffmpegBatchFile;
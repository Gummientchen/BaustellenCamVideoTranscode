<?php
/*

Downloads all images in the given time range from the server

*/

$maxTry = 3;

$hour = 9;
$minute = 00;

if(isset($argv[1])){
	$hour = $argv[1];
}

if(isset($argv[2])){
	$minute = $argv[2];
}

echo "Hour: ".$hour."\n";
echo "Minute: ".$minute."\n";

function progress_bar($done, $total, $info="", $width=50) {
    $perc = round(($done * 100) / $total);
    $bar = round(($width * $perc) / 100);
    return sprintf("%s%%[%s>%s]%s\r", $perc, str_repeat("=", $bar), str_repeat(" ", $width-$bar), $info);
}

$startdate = strtotime("2020-07-25 ".$hour.":".$minute.":00");
$enddate = strtotime("2020-12-31 ".$hour.":".$minute.":00");

$day = $startdate;

$numberOfDays = round(($enddate - $startdate) / (60 * 60 * 24));



$currentday = 0;

while($day <= $enddate){
	// create filename
	$filename = "dl/".$day.".jpg";

	$info = "Day: ".date("d.m.Y - H:i - D", $day);

	if(date("N", $day) < 6){
		if(!file_exists($filename)){ // only download if file doesn't exist
			$url = getUrl($day);
			if(!downloadImage($url, $filename)){
				$tmpday = strtotime("+1 minute", $day);
				$url = getUrl($tmpday);
	
				$try = 0;
	
				// tries to get the next available image
				while(!downloadImage($url, $filename) AND $try < $maxTry){
					$tmpday = strtotime("+1 minute", $tmpday);
					$url = getUrl($tmpday);
	
					$try++;
				}
	
				// deletes file if it couldn't be downloaded
				if($try >= $maxTry){
					unlink($filename);
				}
			}
		}
	}

	// adds 24h to date
	$day = strtotime("+1 day", $day);
	$currentday++;

	echo "\r".progress_bar($currentday, $numberOfDays, $info);
}

echo "\n";

// downloads image
function downloadImage($url, $filename){
	if(file_put_contents( $filename,file_get_contents($url))){
		return true;
	}

	return false;
}

// generates download URL
function getUrl($timestamp){
	$year = date("Y", $timestamp);
	$month = date("m", $timestamp);
	$day = date("d", $timestamp);
	$hour = date("H", $timestamp);
	$minute = date("i", $timestamp);

	$url = "https://srvpowebcam03.webcamserver.ch/cams/cam1805/".$year."/".$month."/".$day."/".$hour."/".$minute.".jpg";

	return $url;
}

?>
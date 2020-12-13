<?php
/*

Downloads all images in the given time range from the server

*/

$maxTry = 3;

$hour = 12;
$minute = 30;

$startdate = strtotime("2020-07-25 ".$hour.":".$minute.":00");
$enddate = strtotime("2020-12-12 ".$hour.":".$minute.":00");

$day = $startdate;

while($day <= $enddate){
	// create filename
	$filename = "dl/".$day.".jpg";

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

	// adds 24h to date
	$day = strtotime("+1 day", $day);
}

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
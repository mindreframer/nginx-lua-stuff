<?php
if(empty($_SERVER['argv'][1])) {
	exit("please input newsid \n");
}
//("rm -rf *.mpr");
//get
$newsid = $_SERVER['argv'][1];

$url = "http://app.test.com/gnews/soundget";
$fields_string = "";

$fields = array(
	'newsid'=>$newsid,
);

foreach ($fields as $key=>$value) {
	$fields_string .= $key.'='.$value.'&';
}

$fields_string = rtrim($fields_string, "&");
$headers = array('X-GNBinder-security:secureheader1');
ob_start();

$ch = curl_init();

curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, count($fields));
curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
//get content 

curl_exec($ch);


curl_close($ch);

$content = ob_get_contents();
ob_end_clean();

$file=$newsid.".mp4";

$fp = fopen($file, "w");
if (!$fp) {
	return false;
}
$flag = fwrite($fp, $content);
fclose($fp);

exit("generate {$newsid}.mp4 ok! \n");

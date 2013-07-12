<?php
/**
 * /tmp/phptidy-sublime-buffer.php
 *
 * @package default
 */


if (empty($_SERVER['argv'][1])) {
	exit("please input newsid \n");
}
//("rm -rf *.mpr");
//get

if ($_SERVER['argv'][1] == "test" && !empty($_SERVER['argv'][2]) && !empty($_SERVER['argv'][3])) {
	$newsid = $_SERVER['argv'][3];
	$count = $_SERVER['argv'][2];
	$total = testMode($newsid, $count);
	$echo = "Total Time:" . $total . "  Send  $count request.";
}else {
	$newsid = $_SERVER['argv'][1];
	testOne($newsid);
}

function testMode($newsid,$count) 
{
	$start = time();
	$per = 0;
	for($i=0;$i<$count;$i++) {
		$now = time();
		testOne($newsid);
		//usleep(mt_rand(1000,10000));
		$per++;
		if($now - $start ==1) {
			printf("tps: ".$per."  Send request: $i  \n");
			$per = 0;
			$start = $now;
		}
		//echo $now."  ".$start."  $per \n";
	}
	$end = time();
	return $end - $start;
}



/**
 *
 *
 * @param unknown $newsid
 * @return unknown
 */
function testOne($newsid) {
	$url = "http://app.test.com/gnews/soundget";
	$fields_string = "";

	$fields = array(
		'newsid'=>$newsid,
	);

	foreach ($fields as $key=>$value) {
		$fields_string .= $key.'='.$value.'&';
	}

	$fields_string = rtrim($fields_string, "&");
	$headers = array('X-GNBinder-security:secureheader');
	ob_start();

	$ch = curl_init();

	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_POST, count($fields));
	curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
	curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
	//get content

	curl_exec($ch);


	curl_close($ch);
	ob_end_clean();
	/*
	$content = ob_get_contents();
	ob_end_clean();

	$file="./file/".$newsid.time().mt_rand(100000, 999999).".mp4";

	$fp = fopen($file, "w");
	if (!$fp) {
		return false;
	}
	$flag = fwrite($fp, $content);
	fclose($fp);
	*/
}

//echo the test result

//exit("generate {$newsid}.mp4 ok! \n");

<?php

ini_set("max_execution_time", "0");
set_time_limit(0);

//output the mp4 file
//
class runtime
{
    var $StartTime = 0;
    var $StopTime = 0;

    function get_microtime()
    {
        list($usec, $sec) = explode(' ', microtime());
        return ((float)$usec + (float)$sec);
    }

    function start()
    {
        $this->StartTime = $this->get_microtime();
    }

    function stop()
    {
        $this->StopTime = $this->get_microtime();
    }

    function spent()
    {
        return round(($this->StopTime - $this->StartTime) * 1000, 1);
    }

}

$runtime = new runtime();
$runtime->start();

//error_log(var_export($_POST,true));
$start = time();

if(!empty($_POST['text']) && !empty($_POST['lang']) && !empty($_POST['newsid'])) {
	$text = trim(urldecode($_POST['text']));
	$infile = $_POST['newsid'];
	$filepath = "./sound/";
	file_put_contents($filepath.$infile,$text);

	$lang = urldecode($_POST['lang']);

	//error_log("info:".$_POST["newsid"]."  ".$lang."  \n".$text."   \n");

	$langtype = "Kyoko";
        switch ($lang) {
	  case "cn":
		$langtype = "Ting-Ting";
		break;
	  case "en":
		$langtype = "Kathy";
		break;
	  case "jp":
		$langtype = "Kyoko";
		break;
	   default:
		$langtype = "Kyoko";
	}

	//run del
	system("say -o ".$filepath.$infile."out.mp4 -v $langtype -f ".$filepath.$infile);
	//error_log("say -o ".$filepath.$infile."out.mp4 -v $langtype -f ".$filepath.$infile);
	/* File Read */
	$filename = $infile."out.mp4";
	if(!file_exists($filepath.$filename)) {
		echo $filepath.$filename."  not exist!";
		error_log($filepath.$filename."  not exist!");
	}else {
		header('Content-Type:application/octet-stream');
		header('Content-Disposition:attachment; filename="'.basename($filename).'"');
		header("Accept-Ranges: bytes");
		header('Accept-Length: '.filesize($filepath.$filename));
		$file = fopen($filepath.$filename,'r');
		echo fread($file,filesize($filepath.$filename));
		fclose($file);
		$runtime->stop();
		error_log("ok..".$_POST["newsid"]."   time(ms):".$runtime->spent());
		exit;

	}

}else{
    error_log("---------params is empty:".var_export($_POST,true));
}


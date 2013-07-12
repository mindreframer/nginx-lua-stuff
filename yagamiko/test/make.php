<?php
if(empty($_SERVER['argv'][1])) {
	exit("please input newsid \n");
}
//("rm -rf *.mpr");
//get
$newsid = $_SERVER['argv'][1];

$url = "http://app.test.com/gnews/soundmake";
$fields_string = "";

$text = "［モスクワ　７日　ロイター］　ロシアと米国は７日、シリアの内戦終結を目指し、アサド政権や反体制派など当事者も参加する国際会議を早ければ今月末に開くことで合意した。


    ロシアのラブロフ外相とケリー米国務長官がモスクワで会談し、合意について発表した。両国はシリア政府と反体制派の双方が会議に参加するよう働き掛けを行うという。


    会議の目的は、米国やロシアなどの関係国が昨年６月、停戦実現に向けて合意した挙国一致「移行政府」への取り組みを再開すること。


    ケリー長官は、交渉による問題解決ができなければ、暴力がさらに拡大すると懸念を表明。人道的な危機が拡大するほか、シリアという国の崩壊にさえつながる可能性もあるとの考えを示した。


    ロシアはこれまで、シリアへの国連制裁に反対してきたほか、同国政府に武器提供を続けている。しかし、ラブロフ外相はこの日、アサド大統領に言及し、ロシアが特定の人物の命運を憂慮することはないと強調した。";
$lang = "jp";
$date="Wed, 08 May 2013 05:59:41 GMT";

$fields = array(
	'newsid'=>urlencode($newsid),
	'newscontext'=>urlencode($text),
	'language'=>urlencode($lang),
	'postdate'=>urlencode($date),
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

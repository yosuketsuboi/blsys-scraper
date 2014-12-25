<?php

$res = file_get_contents("http://localhost/5931/scraper.php?dsmk=$argv[1]&dk=$argv[2]");
echo "========== json ==========\n$res\n========== var_dump ==========\n";
$json = json_decode($res);
var_dump($json);

<?php
require_once('../simple_html_dom.php');

$context = array(
    'http' => array(
        'proxy' => 'tcp://157.109.160.180:8080',
    ),
);

if (!(array_key_exists('dsmk', $_GET) && strlen($_GET['dsmk']) > 0 && array_key_exists('dk', $_GET) && strlen($_GET['dk']) > 0)) {
    header('HTTP/1.1 400 Bad Request');
    exit;
}

$url = 'http://www.kokusaibus.com/blsys/loca?VID=ldt&EID=nt&DSMK=%s&DK=%s';
$html = file_get_html(sprintf($url, $_GET['dsmk'], $_GET['dk']), false, stream_context_create($context));

$content_td = $html->find('#mainContents', 0)->find('table', 0)->find('tr', 0)->find('td', 0);
$busStop = str_replace('停留所名：　', '', $content_td->find('table', 0)->find('tr', 1)->find('td', 0)->find('p', 0)->text());
$modified = str_replace('現在 ', '', str_replace('】', '', str_replace('【', '', $content_td->find('table', 2)->find('tr', 0)->find('td', 0)->find('span', 0)->text())));
$list_tr = $content_td->find('table', 2)->find('tr', 1)->find('td', 0)->find('table', 0)->find('tr');

$results = array();
foreach ($list_tr as $tr) {
    if (count($tr->find('td')) > 0) {
        $results[] = array(
            'scheduled' => $tr->find('td', 0)->text(),
            'actual' => $tr->find('td', 1)->text(),
            'destination' => $tr->find('td', 3)->text(),
            'text' => $tr->find('td', 5)->text(),
        );
    }
}

echo json_encode(array(
        'bus_stop' => $busStop,
        'modified' => $modified,
        'results' => $results,
));

header('Access-Control-Allow-Origin: *');

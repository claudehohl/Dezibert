<?php

$last_tweet = file_get_contents('stamp');
$diff = mktime() - $last_tweet;

l('file aufgerufen');

if(isset($_GET['my']) && $_GET['my'] == 'pass'){

        l('get parameter erhalten');

        if($diff > 10 * 60){

                $to = 'dummy@ping.fm';

                $subjects = array(
                        'Leute. Ihr seid zu laut!',
                        'Techies koennen sich bei diesem Laermpegel nicht konzentrieren.',
                        'Laermpegel bei den Consultants in SG: Unertraeglich.',
                );

                $subject = $subjects[ rand(0, count($subjects)-1) ];

                mail($to, $subject, '');

                echo 'ok';

                file_put_contents('stamp', mktime());

                l('mail verschickt: ' . $subject);

        }

}

function l($t){
        $f = fopen('twitter.log', 'a+');
        fwrite($f, $t . "\n");
        fclose($f);
}


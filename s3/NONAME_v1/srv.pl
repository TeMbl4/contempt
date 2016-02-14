#!/usr/bin/perl -w

package iON;

use strict;
use utf8;

use WWW::Curl::Easy;
use WWW::Curl::Form;
use JSON::XS;
use URI::Escape;
use LWP::UserAgent;

require Encode;

use base qw(Net::Server::Fork);

## Инициализация
################################

$|=1;
our $parent = $$;
our $mp3_data;

################################

for(1..5)
{
  system("perl mic.pl &>/dev/null");
  sleep 1;
}


## Параметры запуска сервера
###############################

iON->run(port => 16000, background => undef, log_level => 4, host => 'localhost');

################################
################################

sub DESTROY
{
 if($$ == $parent)
 {
  system("killall perl");
  system("rm data/*.flac && rm data/*.wav");
 }
}

## Процесс обработки команды
################################

sub process_request
{
    my $self = shift;

    while (<STDIN>)
    {
        if (/text (\d+)/) { toText($1); next; }
        if (/quit/i) { print "+OK - Bye-bye ;)\n\n"; last; }

        print "-ERR - Command not found\n";
    }
}

###############################
###############################

sub toText
{
    my $num = shift;

    print "+OK - Trying recognize text\n";

        my $curl = WWW::Curl::Easy->new;

        $curl->setopt(CURLOPT_HEADER,1);
    $curl->setopt(CURLOPT_POST,1);
    #$curl->setopt(CURLOPT_VERBOSE, 1);

    my @myheaders=();
    $myheaders[0] = "Content-Type: audio/x-flac; rate=16000";

    $curl->setopt(CURLOPT_HTTPHEADER, \@myheaders);
        $curl->setopt(CURLOPT_URL, 'https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=ru-RU');

    	my $curlf = WWW::Curl::Form->new;
    	$curlf->formaddfile("data/input-$num.flac", 'myfile', "audio/x-flac");
    	$curl->setopt(CURLOPT_HTTPPOST, $curlf);

        my $response_body;
        $curl->setopt(CURLOPT_WRITEDATA,\$response_body);

        # Starts the actual request
        my $retcode = $curl->perform;

        # Looking at the results...
        if ($retcode == 0) {

                $response_body =~ /\n\r\n(.*)/g;
        my $json = $1;

        my $json_xs = JSON::XS->new();
        $json_xs->utf8(1);
        my @hypo = $json_xs->decode($json)->{'hypotheses'};

        my $dost = $hypo[0][0]{'confidence'};
        my $text = $hypo[0][0]{'utterance'};

        $dost = 0.0 if !defined $dost;
        $text = "" if !defined $text;

    print "+OK - Text is: \"$text\", confidence is: $dost\n";

    if($dost > 0.5)
    {
        checkcmd($text);
    }
    {
        print "+ERR - Confidence is lower, then 0.5\n";
    }

        } else {
                # Error code, type of error, error message
                print("+ERR - $retcode ".$curl->strerror($retcode)." ".$curl->errbuf);
        }

    system("rm data/input-$num.flac");

}

###############################

## Проверка на комманды
###############################

sub checkcmd
{
    my $text = shift;
    chomp $text;
    $text =~ s/ $//g;

    print "+OK - Got command \"$text\" (Length: ".length($text).")\n";

    if($text =~ /система/)
    {
       sayText("Ваша команда - $text");
         }

    return;
}


## Озвучивание
###############################

sub sayText
{
    my $text = shift;

    print "+OK - Speaking \"$text\"\n";

    my $url = "http://translate.google.com/translate_tts?tl=ru&q=".uri_escape_utf8($text);
    my $ua = LWP::UserAgent->new(
        agent => "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.872.0 Safari/535.2");

    $ua->get($url, ':content_cb' => \&callback);

    open (MP3, "|padsp splay -M") or die "[err] Can't save: $!\n";
        print MP3 $mp3_data;
    close(MP3);

    $mp3_data = undef;

    print "+OK - Done!\n";
    return;
}

sub callback {
   my ($data, $response, $protocol) = @_;
   $mp3_data .= $data; #
}

########################################
########################################

1;

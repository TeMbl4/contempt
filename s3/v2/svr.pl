#!/usr/bin/perl -w

package iON;

use strict;
no warnings 'utf8';
use utf8;
use WWW::Curl::Easy;
use WWW::Curl::Form;
use JSON::XS;
use URI::Escape;
use LWP::UserAgent;
require Encode;
use base qw(Net::Server::Fork);

for(1..5)
{
#  system("perl ./mic.pl &>/dev/null");
#  system("perl ./mic.pl");
  sleep 1;
}

iON->run(port => 16000, background => undef, log_level => 4, host => 'localhost');

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

1;

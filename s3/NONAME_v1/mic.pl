#!/usr/bin/perl

use strict;
use IO::Socket;

while (1)
{
my $rnd = int(rand(1000));

`rec -q -c 1 -r 16000 /home/art/scripts/AI/NONAME_v1/data/input-$rnd.wav trim 0 3`;
`flac -f -s /home/art/scripts/AI/NONAME_v1/data/input-$rnd.wav -o /home/art/scripts/AI/NONAME_v1/data/input-$rnd.flac`;
#`rm /home/art/scripts/AI/NONAME_v1/data/input-$rnd.wav`;

my $sock = new IO::Socket::INET(
        PeerAddr => "localhost",
        PeerPort => 16000,
        Proto => 'tcp') || next;

print $sock "text ".$rnd;
undef $rnd;
}

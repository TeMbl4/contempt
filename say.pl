#!/usr/bin/env perl

require Encode;

use URI::Escape;
use LWP::UserAgent;

our $LANG="en";

our $mp3_data;


$sayIt  = $ARGV[0];

if (!defined($sayIt)) {
	print qq{Sorry you should enter text for speaking\n};
	exit -1;
} else {
    sayText($sayIt);
}

sub sayText
{
	my $text = shift;
	print "+OK - Speaking\n";
	my $url = "http://translate.google.com/translate_tts?tl=".$LANG."&q=".uri_escape_utf8($text)."&client=tw-ob";
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

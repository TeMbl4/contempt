#!/usr/bin/perl

####################
# SEND FILE SERVER #
####################

  use IO::Socket ;

  my $host = '10.100.32.250';
  my $port = $ARGV[0] || 16000 ;
  my $save_dir = '/CONTEMPT/jarvis/data' ;
  
#############
# START SRV #
#############

  if (! -d $save_dir) {
    mkdir($save_dir,0755) ;
    print "Save directory created: $save_dir\n" ;
  }
  
  my $server = IO::Socket::INET->new(
      Listen => 5,
      LocalAddr => $host,
      LocalPort => $port ,
      Proto     => 'tcp'
  ) or die "Can't create server socket: $!";

  print "Server opened: $host:$port\nWaiting clients...\n\n" ;

  while( my $client = $server->accept ) {
    print "\nNew client!\n" ;
    my ($buffer,%data,$data_content) ;
    my $buffer_size = 1 ;

	while( sysread($client, $buffer , $buffer_size) ) {
		$data{filename} .= $buffer ;

	if ($data{filename} !~ /#;#$/) {
		print qq{Working in text mode $data{filename}\n};
	}
	elsif ($data{filename} !~ /#:#$/) {
		print qq{Working in file mode $buffer\n};

		if ($data{filesize} !~ /_$/) { $data{filesize} .= $buffer ;}
		elsif ( length($data_content) < $data{filesize}) {
			if ($data{filesave} eq '') {
				$data{filesave} = "$save_dir/$data{filename}" ;
				$data{filesave} =~ s/#:#$// ;
				$buffer_size = 1024*10 ;
					if (-e $data{filesave}) { 
						unlink ($data{filesave});
					}
					print "Saving: $data{filesave} ($data{filesize}bytes)\n" ;
			}
			open (FILENEW,">>$data{filesave}") ; binmode(FILENEW) ;
				print FILENEW $buffer ;
			close (FILENEW) ;
			print "." ;
		} else { 
			last;
		}
	}
	print "OK\n\n" ;
	}
}


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
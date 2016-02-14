#!/usr/bin/perl

####################
# SEND FILE CLIENT #
####################

  use IO::Socket ;
  $bandwidth = 1024*1024*1024 ; # 1Mb/s
  &send_data( $ARGV[0] , $ARGV[1]||'10.100.32.250' , $ARGV[2]||16000 ) ;
  exit;

##########################
# SEND_DATA file or text #
##########################

sub send_data {
  my ( $data , $host , $port ) = @_ ;
		my $sock = new IO::Socket::INET(
				PeerAddr => $host,
				PeerPort => $port,
				Proto    => 'tcp',
				Timeout  => 30) ;

		if (! $sock) { die "ERROR! Can't connect\n" ;}
		$sock->autoflush(1);

		if ($data =~ /text (\S+)/) { 
			my $file_size = -s $data;
			print "Sending Text: $data\n" ;
			print $sock "$1#;#" ; # send the file name.
			open (FILE,$file) ; 
				my $buffer ;
				while( sysread(FILE, $buffer , $bandwidth) ) {
					print $sock $buffer ;
					print "." ;
					sleep(1) ;
				}
			print "Sent OK\n\n" ;
			close (FILE) ;
			close($sock) ;
		} elsif ($data !~ /text (\S+)/) {
			if (! -s $data) { die "ERROR! Can't find or blank file $data" ;}
			my $file_size = -s $data;
			$file_name = ( $data =~ /([^\\\/]+)[\\\/]*$/gs );

			print "Sending $file_name\n$file_size bytes." ;
			print $sock "$file_name#:#" ; # send the file name.
			print $sock "$file_size\_" ; # send the size of the file to server.
			open (FILE,$file) ; 
			binmode(FILE) ;
				my $buffer ;
				while( sysread(FILE, $buffer , $bandwidth) ) {
					print $sock $buffer ;
					print "." ;
					sleep(1) ;
				}
			print "OK\n\n" ;
			close (FILE) ;
			close($sock) ;
		}
}

#######
# END #
#######

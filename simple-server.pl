#!/usr/bin/perl

use strict;
use warnings;

use IO::Select;
use IO::Socket;
use CardDAP;
use CardDAP::Book;

my $basedn = shift @ARGV;
print "Base path is: $basedn\n";

my $book = new CardDAP::Book($basedn, @ARGV);

my $sock = IO::Socket::INET->new(
	Listen => 5,
	Proto => 'tcp',
	Reuse => 1,
	LocalPort => 8080
) || die $!;

my $sel = IO::Select->new($sock);
my %Handlers;
while (my @ready = $sel->can_read) {
	foreach my $fh (@ready) {
		if ($fh == $sock) {
			# let's create a new socket
			my $psock = $sock->accept;
			$sel->add($psock);
			$Handlers{*$psock} = CardDAP->new($book, $psock);
		} else {
			my $result = $Handlers{*$fh}->handle;
			if ($result) {
				# we have finished with the socket
				$sel->remove($fh);
				$fh->close;
				delete $Handlers{*$fh};
			}
		}
	}
}

1;

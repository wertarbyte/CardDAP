package CardDAP;

use strict;
use warnings;
use Data::Dumper;

use Net::LDAP::Constant qw(LDAP_SUCCESS);
use Net::LDAP::Server;
use base 'Net::LDAP::Server';
use fields qw(book);

use constant RESULT_OK => {
	'matchedDN' => '',
	'errorMessage' => '',
	'resultCode' => LDAP_SUCCESS
};

# constructor
sub new {
	my ($class, $book, $sock) = @_;
	my $self = $class->SUPER::new($sock);
        $self->{book} = $book;
	printf "Accepted connection from: %s\n", $sock->peerhost();
	return $self;
}

# the bind operation
sub bind {
	my $self = shift;
	my $reqData = shift;
	print Dumper($reqData);
	return RESULT_OK;
}

# the search operation
sub search {
	my $self = shift;
	my $reqData = shift;
	print "Searching...\n";
	my $base = $reqData->{'baseObject'};
	my $filter = $reqData->{filter};

	my @entries;
	if ($reqData->{'scope'}) {
                push @entries, $self->{book}->entries;
	} else {
                push @entries, $self->{book}->entries;
	}
	return RESULT_OK, @entries;
}

1;

package CardDAP;

use strict;
use warnings;
use Data::Dumper;

use Net::LDAP::Constant qw(LDAP_SUCCESS);
use Net::LDAP::Server;
use Net::LDAP::Filter;
use Net::LDAP::FilterMatch;
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
	my $filter = bless $reqData->{filter}, "Net::LDAP::Filter";
        print $filter->as_string, "--\n";

	my @entries;
	if ($reqData->{'scope'}) {
            push @entries, grep {$filter->match($_)} $self->{book}->entries;
	} else {
            my $entry = Net::LDAP::Entry->new;
            $entry->dn($base);
            $entry->add(
                dn => $base
            );
            push @entries, $entry;
	}
	return RESULT_OK, @entries;
}

1;

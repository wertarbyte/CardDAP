package CardDAP::Book;

use Text::vCard;
use Text::vCard::Addressbook;
use Net::LDAP::Entry;

sub new {
    my ($class, $base, @files) = @_;
    my $self = { base => $base, file => $file };
    #$self->{abook} = new Text::vCard::Addressbook({source_file => $file});
    $self->{abook} = load Text::vCard::Addressbook( [@files] );
    return bless $self, $class;
}

sub entries {
    my ($self) = @_;
    my @results;
    my $abook = $self->{abook};
    my $base = $self->{base};
    my $id = 0;
    foreach my $vcard ($abook->vcards()) {
        $id++;
        my $entry = new Net::LDAP::Entry;
        $entry->dn("uid=$id, $base");
        $entry->add( objectClass => [qw[top person organizationalPerson inetOrgPerson mozillaAbPersonAlpha]] );
        $entry->add( givenName => $vcard->get('moniker')->[0]->given() );
        $entry->add( cn => $vcard->fullname() );
        $entry->add( uid => $id );
        my @mail = map {$_->value()} @{ $vcard->get("EMAIL") };
        $entry->add( mail => [@mail] );
        $entry->add( telephoneNumer => [ map {$_->value()} @{$vcard->get("tel")} ] );
        push @results, $entry;
    }
    return @results;
}

1;

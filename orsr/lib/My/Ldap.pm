package My::Ldap;

use strict;
use warnings;

use Net::LDAP;
use Net::LDAP::Control::Paged;
use Net::LDAP::Constant qw( LDAP_CONTROL_PAGED );
use Text::Unaccent;
use Config::Tiny;
use 5.010;

use Exporter qw(import);

our @EXPORT_OK = qw(get_empl_names);

#
# Read configuration file
#
my $config_file = "$ENV{HOME}/.myldap";
check_config_exists($config_file);

my $Config = Config::Tiny->read($config_file);
my $server = $Config->{_}->{server};
my $port   = $Config->{_}->{port};
my $binddn = $Config->{_}->{binddn};
my $basedn = $Config->{_}->{basedn};
my $filter = $Config->{_}->{filter};

########################
sub check_config_exists {
########################
    my $config_file = shift;

    unless ( -r $config_file ) {
        print "'$config_file' doesn't exist or is not readable\n";
        print "Should look something like this:\n";
        print <<'EOF';

server=ldap.example.com
port=389
binddn=cn=John Foo,ou=Standard,ou=Users,ou=LONBakerStreet,dc=example,dc=com
basedn=dc=example,dc=com
# To get user objects
filter=(&(objectCategory=person)(objectClass=user))

EOF
        exit 1;
    }
    1;
}

########################
sub ldap_bind {
########################
    my ( $server, $port, $binddn, $pass ) = @_;

    # create Net::LDAP object and open connection to LDAP server
    my $ldap = new Net::LDAP( $server, port => $port )
      or die "Unable to connect to $server: $@\n";

    # bind to a directory with dn a password
    $ldap->bind( $binddn, password => $pass )
      or die "Unable to bind: $@\n";

    return $ldap;    # Net::LDAP object
}

########################
sub get_passwd {
########################
    my $pass;
    system "stty -echo";
    print "Enter LDAP password> ";
    chomp( $pass = <STDIN> );
    system "stty echo";
    print "\n";

    return $pass;
}

########################
sub get_empl_names {
########################

    # Conntect to LDAP server
    my $pass = get_passwd();
    my $ldap = ldap_bind( $server, $port, $binddn, $pass );
    my $page = Net::LDAP::Control::Paged->new( size => 100 );

    my @args = (
        base    => $basedn,
        filter  => $filter,
        control => [$page],
    );

    my @names;
    my $cookie;
    while (1) {

        # Perform search
        my $mesg = $ldap->search(@args);

        while ( my $entry = $mesg->shift_entry() ) {

            if (
                defined( my $name = $entry->get_value('extensionAttribute1') ) )
            {
                push @names, $name;
            }

        }    # while

        # Only continue on LDAP_SUCCESS
        $mesg->code and last;

        # Get cookie from paged control
        my ($resp) = $mesg->control(LDAP_CONTROL_PAGED) or last;
        $cookie = $resp->cookie or last;

        # Set cookie in paged control
        $page->cookie($cookie);
    }

    if ($cookie) {

       # We had an abnormal exit, so let the server know we do not want any more
        $page->cookie($cookie);
        $page->size(0);
        $ldap->search(@args);
    }

    return @names;
}

1;

#!/usr/bin/perl
# Get IP phones that aren't protected by password.
use strict;
use warnings;
use autodie;
use LWP::UserAgent;

# Get IP phones' addresses from file
die "Usage: $0 ip_phones.txt\n" unless $ARGV[0];
open my $fh, "<", $ARGV[0];
chomp( my @ips = <$fh> );

my %no_pass;

for my $ip (@ips) {
    my $ua       = LWP::UserAgent->new;
    my $response = $ua->get("http://$ip:8080");
    if ( $response->is_success )
    {    # phone web interface is no password protected
        $no_pass{$ip}++;
    } else {
        print "$ip: " . $response->status_line . "\n";
    }

}

# Print output
print "-" x 79, "\n";
print "IP phones without password:\n";
for my $ip ( sort keys %no_pass ) {
    print "\t$ip\n" if $no_pass{$ip};
}

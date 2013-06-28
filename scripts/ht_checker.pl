#!/usr/bin/perl
# Get HTTP status codes. Output will be stored to $0.out
use strict;
use warnings;
use LWP::UserAgent;
use autodie;

# Get IP addresses from file or STDIN
die "Usage: $0 <ip_addresses.txt> | -\n" unless $ARGV[0];
chomp( my @ips = <> );

# Configuration section
my @protocols = qw(http https);    # https needs LWP::Protocol::https
my @ports     = qw(80 8080);
my $timeout   = 3;

my %responses;

# Let's handle interrupts (Ctrl+C)
my $int_count;
sub my_int_handler { $int_count++ }
$SIG{'INT'} = 'my_int_handler';

$|++;    # hot pipe (don't buffer output)

my $ips_number = @ips;
my $ips_count;
my $connections_number = @ips * @protocols * @ports;
my $connections_count  = 0;

for my $ip (@ips) {
    $ips_count++;
    my $time = sprintf "%.2f h",
      ( $connections_number - $connections_count ) * $timeout / 3600;
    print
"Connecting to $ip ($ips_count/$ips_number, max. remaining time: $time)\n";
    for my $protocol (@protocols) {
        for my $port (@ports) {
            print "\t$protocol://$ip:$port: ";
            my $ua = LWP::UserAgent->new;
            $ua->timeout($timeout);
            my $response    = $ua->get("$protocol://$ip:$port");
            my $status_line = $response->status_line;
            print "$status_line\n";
            ( my $response_code ) = $status_line =~ /^(\d+).*/;
            push @{ $responses{$response_code} }, "$protocol://$ip:$port";
            $connections_count++;
        }
    }
    if ($int_count) {

        # interrupt was seen!
        print "[ program interrupted... ]\n";
        last;
    }
}

# Print output
( my $outfile = $0 ) =~ s/(\.\w+)?$/.out/; # change suffix, if any, to .out
open my $fh, ">", $outfile;
for my $code ( sort keys %responses ) {
    my $count = @{ $responses{$code} };
    print $fh
">> Response code $code ($count/$connections_count): @{ $responses{$code} }\n";
}
close $fh;
print "Output stored to '$outfile'\n";

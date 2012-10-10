#!/usr/bin/perl
# Ping the hosts and store the result the .csv file named after the input file.
# You may want to run this script like this:
#   $ ./<this_script> hosts.txt &
#   $ tail -f hosts.csv
use strict;
use warnings;
use Net::Ping;
use autodie;

die "Usage: $0 <hosts_file>\n" unless @ARGV == 1;

my $infile = shift;
( my $outfile = $infile ) =~ s/(\.\w+)?$/.csv/;

open( my $in, $infile );
open( my $out, '>', $outfile );

my $p =
  Net::Ping->new();   # defaults to tcp protocol, no special privileges required

select $out;
$| = 1;               # don't keep stuff sitting in the buffer

for my $host (<$in>) {
    chomp $host;
    print "$host;";
    if ( $p->ping( $host, 2 ) ) {
        print "reachable\n";
    }
    else {
        print "NOT reachable\n";
    }
    sleep(1);         # to avoid network flooding
}

select STDOUT;        # change the default output filehandle back

$p->close();
close $in;
close $out;

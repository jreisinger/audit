#!/usr/bin/perl
# Convert nmap scan results from .xml to .csv.
# Based on http://www.jedge.com/wordpress/2009/11/using-perl-to-parse-nmap-xml/
use strict;
use warnings;
use Nmap::Parser;    # CPAN
use 5.010;

my $np     = new Nmap::Parser;
my $infile = $ARGV[0];

$np->parsefile($infile);

#GETTING SCAN INFORMATION

print "Scan Information:\n";
my $si = $np->get_session();
print
  'Number of services scanned: ' . $si->numservices() . "\n",
  'Start Time: ' . $si->start_str() . "\n",
  'Finish Time: ' . $si->time_str() . "\n",
  'Scan Arguments: ' . $si->scan_args() . "\n";

print "Host Name,Ip Address,OS Name,Port,Service Name,Service Product\n";
for my $host ( $np->all_hosts() ) {
    for my $port ( $host->tcp_ports() ) {
        my $service = $host->tcp_service($port);
        my $os      = $host->os_sig;

        my $hostname        = $host->hostname()  // "n/a";
        my $ipv4_addr       = $host->ipv4_addr() // "n/a";
        my $os_name         = $os->name()        // "n/a";
        my $service_name    = $service->name     // "n/a";
        my $service_product = $service->product  // "n/a";
        print $hostname . ","
          . $ipv4_addr . ","
          . $os_name . ","
          . $port . ","
          . $service_name . ","
          . $service_product . "," . "\n";
    }
}

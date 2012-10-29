#!/usr/bin/perl
# Convert nmap scan results from .xml to .csv.
# Based on http://www.jedge.com/wordpress/2009/11/using-perl-to-parse-nmap-xml/
use strict;
use warnings;
use Nmap::Parser;  # CPAN

my $np = new Nmap::Parser;
my $infile = @ARGV[0];

$np->parsefile($infile);

#GETTING SCAN INFORMATION

print "Scan Information:\n";
my $si = $np->get_session();
print
'Number of services scanned: '.$si->numservices()."\n",
'Start Time: '.$si->start_str()."\n",
'Finish Time: '.$si->time_str()."\n",
'Scan Arguments: '.$si->scan_args()."\n";

print "Host Name,Ip Address,MAC Address,OS Name,OS Family,OS Generation,OS Accuracy,Port,Service Name,Service Product,Service Version,Service Confidence\n";
for my $host ($np->all_hosts()){
    for my $port ($host->tcp_ports()){
        my $service = $host->tcp_service($port);
        my $os = $host->os_sig;
        print $host->hostname().",".$host->ipv4_addr().",".$host->mac_addr().",".$os->name.",".$os->family.",".$os->osgen().",".$os->name_accuracy().",".$port.",".$service->name.",".$service->product.",".$service->version.",".$service->confidence()."\n";
        }
}

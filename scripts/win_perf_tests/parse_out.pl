#!/usr/bin/perl
use strict;
use warnings;
use Date::Parse;
use Data::Dumper;
use List::Util qw(sum);

sub mean {
	return sum(@_)/@_;
}

sub format_time {
	# Format time for Date::Parse
	my $in_time = shift;
	
	my $out_time = '2000-01-01T' . $in_time;
	$out_time =~ s/,/./;
	
	return $out_time;
}

# MAIN

my $time_start;
my %run_times;
my ($date, $host, $user);
my %value;

while (<>) {
	$value{date} = (split)[2] if /^date/;
	$value{host} = (split)[1] if /^host/;
	$value{user} = (split)[1] if /^user/;
	if ( /(start|stop)/ ) {
		my ( $action, $cmd, $time ) = split;
		
		$time = format_time($time);
				
		if ( $action eq 'start' ) {
			$time_start = $time;
		}
		
		if ( $action eq 'stop' ) {
			my $diff = sprintf "%0.2f", str2time($time) - str2time($time_start);
			push @{$run_times{$cmd}}, $diff;
		}
	}
}

# Generate output
for my $cmd ( keys %run_times ) {
	my @run_times = @{$run_times{$cmd}};
	$value{$cmd} = sprintf "%0.2f", mean(@run_times);
}

# Date, Hostname, Username, Copy, Compress, Delete
print join ";", @value{qw(date host user copy compress cleanup)};

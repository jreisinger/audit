#!/usr/bin/perl -w
# Convert epoch to human readable time.
use strict;

while (<>) {
  chomp;
  print "$_ is ", epoch2time($_), "\n";
}

sub epoch2time {
  my $time = shift;
  my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
  my ($sec, $min, $hour, $day,$month,$year) = (localtime($time))[0,1,2,3,4,5,6]; 
  # You can use 'gmtime' for GMT/UTC dates instead of 'localtime'
  return "$months[$month], $day, ", ($year+1900), " $hour:$min:$sec";
}

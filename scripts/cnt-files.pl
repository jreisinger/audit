#!/usr/bin/env perl
# Count files on Linux/Unix created by a certain user.
use strict;
use warnings;
use File::Find;

$|++; # don't buffer output

my @start_dirs = @ARGV;

die "Usage: $0 <dirs_to_search>\n" unless @start_dirs;

find(\&what_to_do, @start_dirs);

my %files;
sub what_to_do {
  # count files for uid
  my $uid = (stat)[4];
  $files{$uid}++;
}

sub by_number_of_files { $files{$b} <=> $files{$a} }

for my $uid ( sort by_number_of_files keys %files ) {
  my $user = getpwuid $uid // $uid;
  printf "%12s created %d files\n", $user, $files{$uid};
}

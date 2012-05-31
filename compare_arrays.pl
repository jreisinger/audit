#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

# Array A
my @a = qw{ a b c };
@a = map { "\L$_" } @a; # make elements lowercase

# Array B
my @b = qw{ a b C d };
@b = map { "\L$_" } @b; # make elements lowercase

# Check arrays are the same or not (considering order)
if ( @a ~~ @b ) {
  print "The arrays are the same.\n";
} else {
  print "The arrays are not the same.\n";
}

# Count elements number
printf "A array has %d elements\n", scalar @a;
printf "B array has %d elements\n", scalar @b;

# Find A array alements missing in the B array
my @c;
OUTER:
for ( @a ) {
  for my $pat ( @b ) {
    next OUTER if /\Q$pat/i;
  }
  push @c, $_;
}
say "B array is missing: @c" if @c;

# Find B array alements missing in the A array
@c = ( );
OUTER:
for ( @b ) {
  for my $pat ( @a ) {
    next OUTER if /\Q$pat/i;
  }
  push @c, $_;
}
say "A array is missing: @c" if @c;

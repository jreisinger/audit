#!/usr/bin/perl
# Generate initials, e.g. John Doe => JDO
use strict;
use warnings;

while (<>) {
    my @names = split;
    my $i = 1;
    for my $name ( @names ) {
        if ( $i == 2 ) {
            my $inits =  substr($name, 0, 2);
            print "\U$inits";
        } else {
            print substr($name, 0, 1);
        }
        $i++;
    }
    print "\n";
}

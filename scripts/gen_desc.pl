#!/usr/bin/perl
# Generate README.md from scripts' descriptions.
use strict;
use warnings;
use autodie;

# Extract descriptions from scripts
my %desc;
for my $script ( glob "*.pl *.sh" ) {
    open my $fh, "<", $script;
    chomp( my @lines = <$fh> );
    close $fh;
    my $desc = $lines[1];    # get second line
    if ( $desc =~ /^#/ ) {   # looks like a description, good!
        ( $desc{$script} = $desc ) =~ s/^#\s*(.*)\.$/\l$1/;
    } else {
        $desc{$script} = "no description";
    }
}

# Write the README file
my $readme = 'README.md';
open my $fh, ">", $readme;

print $fh <<EOF;
scripts
-------

Various (quick and dirty) scripts used during audit engagements.

EOF

for my $script ( sort keys %desc ) {
    print $fh "* `$script` - $desc{$script}\n";
}

close $fh;

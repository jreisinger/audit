#!/usr/bin/perl
use strict;
use warnings;
use HTML::LinkExtor;
use LWP::Simple;
use URI::Escape qw(uri_escape);
use Encode qw(encode);
use autodie;

# Load modules from ../lib
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname( abs_path $0) . '/lib';
use My::Ldap qw(get_empl_names);

# Variables
my $base_url   = 'http://www.orsr.sk';
my $script_dir = dirname( abs_path $0);

#
# Get employee names from LDAP
#
my $names_file = "/tmp/names.txt";

if ( -s $names_file and -M _ < 1 ) {    # modified less than 1 day ago
    print "File with names ('$names_file') is fresh\n";
    print "Not getting names from LDAP\n";
} else {

    print "Getting names from LDAP...\n";
    open my $fh, ">", $names_file;
    for my $name ( get_empl_names() ) {
        print $fh $name . "\n";
    }
    close $fh;
}

#
# Setup I/0
#
open my $fh, "<:utf8", $names_file;
my @names = <$fh>;
close $fh;

my $script_name = $0;
$script_name =~ s/\.[^\.]+$/.csv/;
my $out_file    = $script_dir . "/" . $script_name;
open my $out_fh, ">:utf8", $out_file;

$script_name =~ s/\.[^\.]+$/.err/;
my $err_file = $script_dir . "/" . $script_name;
open my $err_fh, ">:utf8", $err_file;

$|++;    # make current (last selected with 'select') FH hot
binmode( STDOUT, ":utf8" );

#
# Loop over names
#
for my $name (@names) {
    chomp $name;
    print "Working on '$name' ... ";

    # Prepare name
    my @names = split ' ', $name;
    if ( scalar @names ne 2 ) {    # strange name
        print "Skipping: >$name<\n";
        select $err_fh;
        $|++;
        print "Skipping: >$name<\n";
        select STDOUT;
        next;
    }

    # Thank you PerlMonks - http://perlmonks.org/?node_id=1024748
    my $gname   = uri_escape encode( 'Windows-1250', $names[0] );
    my $surname = uri_escape encode( 'Windows-1250', $names[1] );

    # Get info on name from orsr.sk
    my $url =
"${base_url}/hladaj_osoba.asp?PR=${surname}&MENO=${gname}&SID=0&T=f0&R=on";
    sleep int rand(3);    # lets be decent and wait for some random time
    my @ids = get_ids($url);

    # Print informative output and store CSV to a file
    print "associated with ", scalar @ids, " companies\n";
    select $out_fh;
    $|++;
    printf "%s;%s;%s\n", $names[1], $names[0], scalar @ids;
    select STDOUT;
}

####################
sub get_ids {
####################
    my $url = shift;

    my @ids;    # internal ORSR IDs
    my $parser = HTML::LinkExtor->new();
    $parser->parse( get $url)->eof;
    for my $linkarray ( $parser->links ) {
        my @element = @$linkarray;
        my ( $elt_type, $attr_name, $link ) = @element;
        if ( $elt_type eq 'a' and $attr_name eq 'href' ) {

            # vypis.asp?ID=101797&SID=5&P=0
            push @ids, $1 if $link =~ /^vypis\.asp\?ID=(\d+).*P=0$/;
        }
    }

    return @ids;
}

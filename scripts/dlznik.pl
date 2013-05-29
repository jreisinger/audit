#!/usr/bin/perl
# Get list of bankrupted companies (in CSV format).
# Usage: perl dlznik.pl > dlznici.csv
use strict;
use warnings;
use open qw(:std :utf8);    # undeclared streams in UTF-8
use utf8;                   # UTF-8 in source code
use LWP::Simple;
use HTML::TreeBuilder;
use HTML::TableExtract;

my $base_url = 'http://dlznik.zoznam.sk';

$|++;

## Zozbieraj linky na dlznikov
my @links;
my $n = 1;
while ( my $content = get "$base_url/vyhlasene-konkurzy?stranka=$n" ) {
    $n++;

    my $tree = HTML::TreeBuilder->new;    # empty tree
    $tree->parse_content($content);

    my @elements = $tree->look_down( 'href', qr/.*/ );

    for my $e (@elements) {

        for ( @{ $e->extract_links( 'a', 'img' ) } ) {
            my ( $link, $element, $attr, $tag ) = @$_;
            push @links, $link if $link =~ /vyhlasene-konkurzy\/.+/;
        }

    }

    # Every 10 pages
    unless ( $n % 10 ) {
        print STDERR "Extracted " . scalar @links . " links from $n pages\n";

        #sleep int rand(5);    # lets be decent and wait for some random time
    }
}

## Vyber z liniek udaje, ktore nas zaujimaju
my @dlznici;
$n = 0;
for my $link (@links) {
    my $content = get "$base_url$link";
    my $tree    = HTML::TreeBuilder->new;    # empty tree
    $tree->parse_content($content);
    my @elements = $tree->look_down( _tag => 'tr', class => 'row2' );

    for my $e (@elements) {
        my $text = $e->as_text;
        if ( $text =~ /IČO/ ) {             # pravnicka osoba
            my ( $meno, $adresa, $ico, $datum ) = $text =~
/(.*)\s+Výpis z obchodného registra(.*)IČO:\s(\d+).*Vyhlásenie:\s([\d\.]+)/;
            $meno =~ s/\s+$//;
            push @dlznici,
              {
                meno   => $meno,
                adresa => $adresa,
                ico    => $ico,
                datum  => $datum,
              };
        } else {                             # fyzicka osoba
            my ( $meno, $adresa, $datum ) =
              $text =~ /(.*)\s{2,}(.*)Súd:.*Vyhlásenie:\s([\d\.]+)/;
            $meno   =~ s/\s+$//;
            push @dlznici,
              {
                meno   => $meno,
                adresa => $adresa,
                ico    => "n/a",
                datum  => $datum,
              };
        }

    }
    $n++;
    print STDERR "Parsed $n links out of " . scalar @links . " links\n"
      unless $n % 100;
}

## Vytlac udaje
for my $dlznik (@dlznici) {
    print join( ";", @$dlznik{qw(meno adresa ico datum)} ) . "\n";
}

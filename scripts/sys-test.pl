#!/usr/bin/perl
use strict;
use warnings;
use User::pwent;    # overrides normal getpwent()
use Test::More 'no_plan';

## Configuration

my @files = (
    {
        name  => '/etc/passwd',
        owner => 'root',
        group => 'root',
        perms => '0644',
    },
    {
        name  => '/etc/group',
        owner => 'root',
        group => 'root',
        perms => '0644',
    },
    {
        name  => '/etc/shadow',
        owner => 'root',
        group => 'shadow',
        perms => '0640',
    },
);

## Collect info

my $out_file = "$0.out";
$out_file =~ s/(\.pl)//;
open my $out_fh, ">", $out_file or die "Can't open $out_file: $!";

select $out_fh;

# Collect users from /etc/passwd
my $fmt = "%15s %35s %20s %20s\n";
printf $fmt, qw(Name Gecos Home Shell);
while ( my $pwent = getpwent() ) {
    printf $fmt, $pwent->name, $pwent->gecos, $pwent->dir, $pwent->shell;
}

select STDOUT;

close $out_fh;

__END__

## Run checks

# Files' owner and permissions
for my $file (@files) {
    my $name  = $file->{name};
    my $perms = $file->{perms};
    my $owner = $file->{owner};
    my $group = $file->{group};
    is( access_rights($name), $perms, "perms of $name" );
    is( owner($name),         $owner, "owner of $name" );
    is( group($name),         $group, "group of $name" );
}

## Functions

sub owner {
    my $filename = shift;
    return unless -e $filename;
    my ( $uid, $gid ) = ( stat($filename) )[ 4, 5 ];
    my $owner = getpwuid($uid);
    return $owner;
}

sub group {
    my $filename = shift;
    return unless -e $filename;
    my ( $uid, $gid ) = ( stat($filename) )[ 4, 5 ];
    my $group = getgrgid($gid);
    return $group;
}

sub access_rights {
    my $filename = shift;
    return unless -e $filename;
    my $mode = ( stat($filename) )[2];
    my $perms = sprintf "%04o", $mode & 07777;    # discard file type info
    return $perms;
}

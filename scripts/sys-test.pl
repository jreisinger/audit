#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';

## Configuration

my @files = (
    {
        name  => '/etc/passwd',
        owner => 'root',
        perms => '0644',
    },
    {
        name  => '/etc/group',
        owner => 'root',
        perms => '0644',
    },
    {
        name  => '/etc/shadow',
        owner => 'root',
        perms => '0640',
    },
);

## Run checks

# Files' owner and permissions
for my $file (@files) {
    my $name  = $file->{name};
    my $perms = $file->{perms};
    my $owner = $file->{owner};
    is( access_rights($name), $perms, "perms of $name" );
    is( owner($name),         $owner, "owner of $name" );
}

sub owner {
    my $filename = shift;
    my $uid      = ( stat($filename) )[4];
    my $owner    = getpwuid($uid);
    return $owner;
}

sub access_rights {
    my $filename = shift;
    my $mode     = ( stat($filename) )[2];
    my $perms    = sprintf "%04o", $mode & 07777;    # FIXME: undestand this
    return $perms;
}

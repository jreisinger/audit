#!/bin/bash
# Discover Windows shares.
#
# Based on Hacking Windows shares from Linux with Samba
# (http://www.madirish.net/59).
#
# Usage:
#   $ $0 <hostnames.txt> > results.txt 2>&1
#   $ grep -A2 Sharename results.txt | grep -v Sharename | grep -v '\-\-\-' | less

for hostname in `cat $1`
do
    echo ">> working on '$hostname'"
    nc -w 3 -z $hostname 139 && smbclient -L \\$hostname -N
done

#!/bin/bash

for host in `cat ips.txt | grep -v '^#' | sed 's#/.*##'`
do
  total=$(($total+1))
  ping -n -c 2 -q $host > /dev/null
  if [ $? -eq 0 ]; then
    echo "$host seems up"
    up=$(($up+1))
  else
    echo "$host seems down"
    down=$(($down+1))
  fi
done

echo "total: $total"
echo "up: $up"
echo "down: $down"

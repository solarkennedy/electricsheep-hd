#!/bin/bash
while read line; do
  id=`echo $line | cut -f 2 -d =`
  echo Fetching Sheep $id
  padded_id=`printf "%05d" $id`
  wget "http://v2d7c.sheepserver.net/gen/244/${id}/electricsheep.244.${padded_id}.flam3" -c
  sleep 1s
done < sheeplist.txt

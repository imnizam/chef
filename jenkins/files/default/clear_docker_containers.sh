#!/bin/bash

containers=`docker ps -a | awk '/Exited|Created/ {print $1}'`
if [ ${#containers[@]} -ne 0 ]; then
  for container in ${containers[@]}
  do
    created_dt=`docker inspect --format='{{.Created}}' --type=container ${container}`
    curr_dt=`date -Ins`
    d1=`date +%s -d $created_dt`
    d2=`date +%s -d $curr_dt`
    ((diff_sec=d2-d1))
    ((mins=diff_sec/60))

    if [ "$mins" > 30 ]; then
      docker rm -f ${container}
    fi
  done
fi
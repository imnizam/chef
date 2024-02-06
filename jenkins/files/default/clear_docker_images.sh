#!/bin/bash

#
# Removing all images that are specific to prod or staging
# registry and are older then 60 mins
#

images=`docker images | awk 'NR>1{print $3}'`
if [ ${#images[@]} -ne 0 ]; then
  for image in ${images[@]}
  do
    docker inspect --format={{.RepoTags}}  --type=image ${image} | grep "myorg.vpc"
    if [ $? == 0 ];then
      created_dt=`docker inspect --format='{{.Created}}' --type=image ${image}`
      curr_dt=`date -Ins`
      echo $curr_dt
      d1=`date +%s -d $created_dt`
      d2=`date +%s -d $curr_dt`
      ((diff_sec=d2-d1))
      ((mins=diff_sec/60))
      if test $mins -ge 60
      then
   docker rmi -f ${image}
      fi
    fi
  done
fi
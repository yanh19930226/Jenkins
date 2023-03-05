#!/bin/bash
harbor_url=$1
project_name=$2
tagImageName=$3
port=$4
containerport=$5
 
# 登录Harbor私服

docker login -u admin -p Harbor12345 $harbor_url

docker stop $project_name

docker rm $project_name

docker run -d -p $port:$containerport --name $project_name $tagImageName

echo   "已执行回滚操作，回滚版本'$tagImageName'"
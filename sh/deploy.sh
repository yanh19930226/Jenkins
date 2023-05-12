#!/bin/sh
#接收外部参数
harbor_url=$1
project_name=$2
tagImageName=$3
port=$4
containerport=$5

echo "开始执行脚本" > "/opt/log.txt"

#查询容器是否存在，存在则删除
containerId=`docker ps -a | grep -w ${project_name} | awk '{print $1}'`
if [ "$containerId" != "" ] ; then
    #停掉容器
    docker stop $containerId
    #删除容器
    docker rm $containerId
    echo "成功删除容器" >> "/opt/log.txt"
fi

#模糊删除镜像
imageId=`docker images | grep -w ${tagImageName} | awk '{print $3}'`
if [ "$imageId" != "" ] ; then
    #删除镜像       
    docker rmi -f $imageId
    echo "成功删除镜像" >> "/opt/log.txt"
#删除none镜像
    
fi
# 登录Harbor私服
docker login -u harbor -p 1234567890Yh! $harbor_url

echo "docker login -u harbor -p 1234567890Yh! $harbor_url" >> "/opt/log.txt"

# 下载镜像
docker pull $tagImageName

echo "拉取镜像成功:docker pull $tagImageName" >> "/opt/log.txt"

# 启动容器
docker run -d -p $port:$containerport --name $project_name $tagImageName

echo "运行容器成功:docker run -d -p $port:$containerport --name $project_name $tagImageName" >> "/opt/log.txt"

docker rmi `docker images|grep none| awk '{print $3}'`

echo "删除虚悬镜像,容器启动成功" >> "/opt/log.txt"

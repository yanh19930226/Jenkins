#!/bin/sh
#接收外部参数
harbor_url=$1
project_name=$2
tagImageName=$3
port=$4
containerport=$5

echo "$tagImageName" > "/opt/log.txt"

#查询容器是否存在，存在则删除
containerId=`docker ps -a | grep -w ${project_name} | awk '{print $1}'`
if [ "$containerId" != "" ] ; then
    #停掉容器
    sudo docker stop $containerId
    #删除容器
    sudo docker rm $containerId
    echo "成功删除容器1" >> "/opt/log.txt"
fi

#模糊删除镜像
imageId=`docker images | grep -w ${tagImageName} | awk '{print $3}'`
if [ "$imageId" != "" ] ; then
    #删除镜像       
    sudo docker rmi -f $imageId
    echo "成功删除镜像2" >> "/opt/log.txt"
#删除none镜像
    
fi
# 登录Harbor私服
sudo docker login -u harbor -p 1234567890Yh! $harbor_url

echo "docker login -u harbor -p 1234567890Yh! $harbor_url" >> "/opt/log.txt"

# 下载镜像
sudo docker pull $tagImageName

echo "docker pull $tagImageName" >> "/opt/log.txt"

# 启动容器
sudo docker run -d -p $port:$containerport --name $project_name $tagImageName

echo "docker run -d -p $port:$containerport --name $project_name $tagImageName" >> "/opt/log.txt"

sudo docker rmi `docker images|grep none| awk '{print $3}'`

echo "容器启动成功!!!" >> "/opt/log.txt"

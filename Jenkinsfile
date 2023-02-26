// def tools = new org.devops.tools()

def AppName = "${JOB_NAME}"
def HOST_IP = ['ip1','ip2']
def createVersion() {
return new Date().format('yyyyMMddHHmmss') + "_${env.BUILD_ID}"
}
def deployment(HOSTIP){
timestamps {
script {
NacosRequestUrl = "http://${HOSTIP}:${PORT}/nacos/getStatus"
try {
result = httpRequest "${NacosRequestUrl}"
print("输出状态码")
print("${result.status}")
// 判断是否返回 200
if ("${result.status}" == "200") {
print "Http 请求成功"
sh """
echo "======== 执行 nacos 服务优雅下线 ========"
curl http://${HOSTIP}:${PORT}/nacos/deregister
sleep 10
sh ./docker_deploy.sh ${AppName} ${PORT} ${dockerImageName} ${HOSTIP} ${ENVIRONMENT}
"""
}
}
catch(Exception e){
sh """
echo ""======== 服务已下线,不需要执行优雅下线命令 "========"
sh ./docker_deploy.sh ${AppName} ${PORT} ${dockerImageName} ${HOSTIP} ${ENVIRONMENT}
"""
}
}
}

}

def healthcheck(HOSTIP){
timestamps {
script {
// 设置检测延迟时间 10s,10s 后再开始检测
sleep 30
// 健康检查地址
httpRequestUrl = "http://${HOSTIP}:${PORT}/${params.HTTP_REQUEST_URL}"
// 循环使用 httpRequest 请求，检测服务是否启动
for(n = 1; n <= "${params.HTTP_REQUEST_NUMBER}".toInteger(); n++){
try{
// 输出请求信息和请求次数
print "访问服务：${AppName} \n" +
"访问地址：${httpRequestUrl} \n" +
"访问次数：${n}"
// 如果非第一次检测，就睡眠一段时间，等待再次执行 httpRequest 请求
if(n > 1){
sleep "${params.HTTP_REQUEST_INTERVAL}".toInteger()
}
// 使用 HttpRequest 插件的 httpRequest 方法检测对应地址
result = httpRequest "${httpRequestUrl}"
// 判断是否返回 200
if ("${result.status}" == "200") {
print "Http 请求成功，流水线结束"
break
}
}
catch(Exception e){
print "监控检测失败，将在 ${params.HTTP_REQUEST_INTERVAL} 秒后将再次检测。"
// 判断检测次数是否为最后一次检测，如果是最后一次检测，并且还失败了，就对整个 Jenkins 任务标记为失败
if (n == "${params.HTTP_REQUEST_NUMBER}".toInteger()) {
currentBuild.result = "FAILURE"
}
}
}
}
}

}
pipeline {
agent { label 'master' }
environment {
version = createVersion()
AppName = "${JOB_NAME}"
}
//清理空间
stages {
stage('Clean阶段') {
steps {
timestamps {
cleanWs(
cleanWhenAborted: true,
cleanWhenFailure: true,
cleanWhenNotBuilt: true,
cleanWhenSuccess: true,
cleanWhenUnstable: true,
cleanupMatrixParent: true,
disableDeferredWipeout: true,
deleteDirs: true
)
}
}
}
stage('Git 阶段') {
when {
environment name: 'mode',value:'Deploy'
}
steps {
echo "start fetch code from git ${GIT_PROJECT_URL}"
buildDescription "发布机器：${HOST_IP} 构建模块: ${MODULE} 构建构建分支：${GIT_BRANCH}"
deleteDir()

checkout([$class: 'GitSCM',
branches: [[name: '*/master']],
extensions: [],
userRemoteConfigs: [[credentialsId: '4738804f-6a89-4149-9efa-a7cfa3d94536',
url: "${GIT_PROJECT_URL}"
]]])
script {
BUILD_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
}
echo "${BUILD_TAG}"
}
}

stage('Docker构建阶段') {
when {
environment name: 'mode',value:'Deploy'
}
steps {
timestamps {
script {
// 创建 Dockerfile 文件，但只能在方法块内使用
configFileProvider([configFile(fileId: "${params.DOCKER_DOCKERFILE_ID}", targetLocation: "Dockerfile-Template")]){
// 设置 Docker 镜像名称
dockerImageName = "${params.HARBOR_URL}/${params.ENVIRONMENT}:${BUILD_TAG}"
// 读取 Dockerfile 文件
dockerfile = readFile encoding: "UTF-8", file: "Dockerfile-Template"
// 替换 Dockerfile 文件中的变量，生成新的 NewDockerfile 文件
NewDockerfile = dockerfile.replaceAll("#PORT","${params.PORT}")
.replaceAll("#MODULE","${params.MODULE}")
writeFile encoding: 'UTF-8', file: './Dockerfile', text: "${NewDockerfile}"
// 输出新的Dockerfile 文件内容
sh "cat Dockerfile"
echo "${dockerImageName}"
// 判断 DOCKER_HUB_GROUP 是否为空，有些仓库是不设置仓库组的
if ("${params.ENV}" == '') {
dockerImageName = "${params.HARBOR_URL}:${BUILD_TAG}"
}
// 提供 Docker 环境，使用 Docker 工具来进行 Docker 镜像构建与推送
docker.withRegistry("http://${params.HARBOR_URL}", "${params.HARBOR_CREADENTIAL}") {
def customImage = docker.build("${dockerImageName}")
customImage.push()
}
}
configFileProvider([configFile(fileId: "docker_deploy", targetLocation: "docker_deploy.sh")]){
sh "cat docker_deploy.sh"
sh "chmod 755 docker_deploy.sh"
}

}
}
}
}
stage('Docker xxxxxx 发布阶段'){
when {
environment name: 'MODE',value:'Deploy'
}
steps{
deployment("${HOST_IP[0]}")
}
}
stage('Docker xxxxxx 健康检查阶段'){
steps {
healthcheck("${HOST_IP[0]}")
}
}
stage('Docker xxxxxx 发布阶段'){
when {
environment name: 'MODE',value:'Deploy'
}
steps{
deployment("${HOST_IP[1]}")
}
}
stage('Docker xxxxxxx 健康检查阶段'){
steps {
healthcheck("${HOST_IP[1]}")
}
}
}
//构建后操作
post{
success{
script{
if(params.MODE == 'Deploy'){
//tools.PrintMes("========pipeline executed successfully========",'green')

} else {
// tools.PrintMes("========pipeline executed successfully========",'green')

}
}
}
failure{
script{
if(params.MODE == 'Deploy'){
//tools.PrintMes("========pipeline execution failed========",'red')

} else {
//tools.PrintMes("========pipeline execution failed========",'red')

}
}
}
unstable{
script{
if(params.MODE == 'Deploy'){
//tools.PrintMes("========pipeline execution unstable========",'red')

} else {
//tools.PrintMes("========pipeline execution unstable========",'red')

}
}
}
aborted{
script{
if(params.MODE == 'Deploy'){
//tools.PrintMes("========pipeline execution aborted========",'blue')

} else {
// tools.PrintMes("========pipeline execution aborted========",'blue')

}
}
}
}
}
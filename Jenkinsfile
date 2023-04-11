pipeline {
  environment {
    registry = 'registry-intl.ap-southeast-1.aliyuncs.com/swmeng/beautifood-lite-'
    registryCredential = 'aliclouddocker'
    DOCKER_CREDENTIALS = credentials('aliclouddocker')
    CDN_REFRESH = credentials('chklcdn')
    DISCORD_WEBHOOK = credentials('DISCORD_BEAUTIFOOD')
  }
  agent any
      stages {
        stage('Build Images') {
          steps{
            script {
              clientImage = docker.build(registry + 'client', '--build-arg ENABLED_MODULES="brotli" --build-arg BUILD_NUM=$BUILD_NUMBER --memory 1500m ./client')
            }
          }
        }
        stage('Push Images') {
          steps {
            script {
              docker.withRegistry('https://registry-intl.ap-southeast-1.aliyuncs.com', registryCredential ) {
                clientImage.push("${env.BUILD_NUMBER}")
                clientImage.push('latest')
              }
            }
          }
        }
        stage('Remove Unused Docker Image') {
          steps {
            sh "docker rmi ${registry}client"
          }
        }
        stage('Deploy Images') {
          steps {
            sshagent(credentials:['JomLuz_GCP']) {
                // sh 'ssh -o StrictHostKeyChecking=no soh@47.254.213.218 \"rm -rf deploy/\"'
                sh 'scp -o StrictHostKeyChecking=no -r ./deploy/* soh@34.124.183.201:/home/soh/beautifood-lite'
                sh "ssh -o StrictHostKeyChecking=no soh@34.124.183.201 \"export BUILD_NUMBER=${env.BUILD_NUMBER} && docker login -u $DOCKER_CREDENTIALS_USR -p $DOCKER_CREDENTIALS_PSW registry-intl.ap-southeast-1.aliyuncs.com && cd /home/soh/beautifood-lite && sh ./deploy.sh\""
              }
          }
        }
        stage('Notify Webhook') {
          steps {
            sh ('curl -H \"Content-Type: application/json\" -d \'{\"username\": \"Jenkins\", \"content\": \"Build \'\"$BUILD_NUMBER\"\' succeed!\"}\' $DISCORD_WEBHOOK')
          }
        }
      }
}

pipeline {
  agent any
  environment {
    ECR_REGISTRY = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com"
    ECR_REPO     = "usermanagement-service"
    IMAGE_TAG    = "${GIT_COMMIT}"
    AWS_REGION   = "us-east-1"
    }
  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/shankarraghuraman/usermanagement-service.git'
      }
    }
    stage('Build JAR with Maven') {
      steps {
        sh 'mvn clean package'
      }
    }
    stage('Docker Build') {
      steps {
        sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
      }
    }
    stage('Push to ECR') {
      steps {
        script {
          sh '''
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
          docker tag $ECR_REPO:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
          docker push $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
          '''
        }
      }
    }
  }
  post {
    success {
      build job: 'Deploy-to-ECS', parameters: [string(name: 'IMAGE_TAG', value: "${IMAGE_TAG}")]
    }
  }
}


pipeline {
  agent any

  environment {
    ECR_REGISTRY = "434748569008.dkr.ecr.us-east-1.amazonaws.com"
    ECR_REPO     = "usermanagement-service"
    IMAGE_TAG    = "${GIT_COMMIT}"
    AWS_REGION   = "us-east-1"
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'feature/shankar',
            credentialsId: 'da56260c-c9a4-4c3f-9962-73583d6c5f7b',
            url: 'https://github.com/shankarraghuraman/usermanagement-service.git'
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

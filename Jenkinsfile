pipeline {
  agent any

  environment {
    AWS_ACCOUNT_ID = '434748569008'
    AWS_REGION     = 'us-east-1'
    ECR_REPO       = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/shankar/usermgmt"
    COMMIT_SHA     = ''
    IMAGE_TAG      = ''
  }

  stages {
    stage('Checkout & Build') {
      steps {
        checkout scm
        sh 'mvn clean package -DskipTests'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          COMMIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          IMAGE_TAG = "${COMMIT_SHA}"
        }
        sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
      }
    }

    stage('Push to ECR') {
      environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
      }
      steps {
        sh 'echo "$(aws ecr get-login-password --region ${AWS_REGION})" | docker login --username AWS --password-stdin ${ECR_REPO}'
        sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
      }
    }

    stage('Terraform Init') {
      steps {
        dir('terraform') {
          sh """
            docker run --rm -v $(pwd):/workspace -w /workspace \
              -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION=${AWS_REGION} \
              hashicorp/terraform:1.8.5 init
          """
        }
      }
    }

    stage('Terraform Import (if needed)') {
      steps {
        dir('terraform') {
          sh """
            set +e
            docker run --rm -v $(pwd):/workspace -w /workspace \
              -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION=${AWS_REGION} \
              hashicorp/terraform:1.8.5 import aws_ecs_cluster.this sha_CI_CD-Demo
            docker run --rm -v $(pwd):/workspace -w /workspace \
              -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION=${AWS_REGION} \
              hashicorp/terraform:1.8.5 import aws_iam_role.ecs_task_execution_role ecsTaskExecutionRole
            set -e
          """
        }
      }
    }

    stage('Terraform Plan & Apply') {
      steps {
        dir('terraform') {
          sh """
            docker run --rm -v $(pwd):/workspace -w /workspace \
              -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION=${AWS_REGION} \
              hashicorp/terraform:1.8.5 plan \
              -var=image_uri=${ECR_REPO}:${IMAGE_TAG} \
              -var='subnet_ids=["subnet-0346e6a7e56b71359","subnet-0f98666a4bbb16c0f"]' \
              -var=security_group_id=sg-06763288ca7ac2b1f
          """
          sh """
            docker run --rm -v $(pwd):/workspace -w /workspace \
              -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION=${AWS_REGION} \
              hashicorp/terraform:1.8.5 apply -auto-approve \
              -var=image_uri=${ECR_REPO}:${IMAGE_TAG} \
              -var='subnet_ids=["subnet-0346e6a7e56b71359","subnet-0f98666a4bbb16c0f"]' \
              -var=security_group_id=sg-06763288ca7ac2b1f
          """
        }
      }
    }
  }

  post {
    success {
      echo '✅ CI/CD pipeline completed successfully.'
    }
    failure {
      echo '❌ CI/CD pipeline failed.'
    }
  }
}

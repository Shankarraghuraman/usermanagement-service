pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '434748569008.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY = 'shankar/usermgmt'
        GIT_BRANCH = 'feature/shankar'
        GIT_REPO = 'https://github.com/shankarraghuraman/usermanagement-service.git'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: "${env.GIT_REPO}", credentialsId: 'github-creds'
                script {
                    COMMIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    IMAGE_TAG = "${COMMIT_SHA}"
                    env.IMAGE_TAG = IMAGE_TAG
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .
                        docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    script {
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                            docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                        """
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir('terraform') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Import (if needed)') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir('terraform') {
                        // Skip failure if already imported
                        sh 'terraform import aws_ecs_task_definition.usermgmt_task usermgmt-task || true'
                    }
                }
            }
        }

        stage('Terraform Plan & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir('terraform') {
                        sh 'terraform plan -out=tfplan'
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD pipeline completed successfully!'
        }
        failure {
            echo '❌ CI/CD pipeline failed.'
        }
    }
}

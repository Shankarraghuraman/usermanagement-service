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
        stage('Clone Repo') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: "${env.GIT_REPO}", credentialsId: 'github-creds'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def COMMIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def IMAGE_TAG = "${COMMIT_SHA}"
                    sh "docker build -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    sh """
                        aws --version
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:\$(git rev-parse --short HEAD)
                    """
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('infra') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Import (if needed)') {
            steps {
                dir('infra') {
                    sh 'terraform import aws_ecs_task_definition.usermgmt_task usermgmt-task || true'
                }
            }
        }

        stage('Terraform Plan & Apply') {
            steps {
                dir('infra') {
                    sh 'terraform plan -out=tfplan'
                    sh 'terraform apply -auto-approve tfplan'
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

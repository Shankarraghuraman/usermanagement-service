pipeline {
    agent any

    environment {
        AWS_REGION     = 'us-east-1'
        ECR_REGISTRY   = '434748569008.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY = 'shankar/usermgmt'
        GIT_BRANCH     = 'feature/shankar'
        GIT_REPO       = 'https://github.com/shankarraghuraman/usermanagement-service.git'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: "${env.GIT_REPO}", credentialsId: 'github-creds'
                script {
                    env.COMMIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                }
            }
        }

        stage('Build Maven Package') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh '''
                        echo "📦 Building Maven package..."
                        mvn clean package
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        echo "🐳 Building Docker image..."
                        docker build -t ${ECR_REPOSITORY}:${COMMIT_SHA} .
                        docker tag ${ECR_REPOSITORY}:${COMMIT_SHA} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${COMMIT_SHA}
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-creds' 
                ]]) {
                    sh """
                        echo "🔐 Logging in to ECR..."
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        echo "📤 Pushing Docker image to ECR..."
                        docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${COMMIT_SHA}
                    """
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-creds' 
                ]]) {
                    dir('terraform') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-creds' 
                ]]) {
                    dir('terraform') {
                        sh """
                            echo "🧩 Running terraform plan and apply..."
                            terraform plan -var="image_tag=${COMMIT_SHA}" -out=tfplan
                            terraform apply -auto-approve tfplan
                        """
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

pipeline {
    agent any

    environment {
        AWS_REGION     = 'us-east-1'
        ECR_REGISTRY   = '434748569008.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY = 'shankar/usermgmt'
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/feature/shankar']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/shankarraghuraman/usermanagement-service.git',
                        credentialsId: 'github-creds'
                    ]]
                ])
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
                    env.IMAGE_TAG = COMMIT_SHA
                    sh "docker build -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.IMAGE_TAG} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    sh '''
                        aws --version
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
                        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir('terraform') {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            export AWS_REGION=$AWS_REGION

                            terraform init
                            terraform import aws_ecs_task_definition.usermgmt_task usermgmt-task || true
                            terraform plan -out=tfplan
                            terraform apply -auto-approve tfplan
                        '''
                    }
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

pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '434748569008.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY = 'shankar/usermgmt'
        GIT_BRANCH = 'feature/shankar'
        GIT_REPO = 'https://github.com/shankarraghuraman/usermanagement-service.git'
        GITHUB_CREDENTIALS = 'github-creds'
        AWS_CREDENTIALS_ID = 'bce35d9c-d0a5-4ec0-9e3d-45073158f3d0'
        ECS_CLUSTER = 'sha_CI_CD-Demo'
        ECS_SERVICE = 'usermgmt-service'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: "${GIT_BRANCH}",
                    url: "${GIT_REPO}",
                    credentialsId: "${GITHUB_CREDENTIALS}"
            }
        }

        stage('Build Maven Package') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    COMMIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    IMAGE_TAG = "${COMMIT_SHA}"
                    env.IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

                    sh """
                        docker build -t ${IMAGE_URI} .
                    """
                }
            }
        }

        stage('Login & Push to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        docker push ${IMAGE_URI}
                    """
                }
            }
        }

stage('Terraform Apply - ECS Infrastructure') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "${AWS_CREDENTIALS_ID}"
        ]]) {
            dir('terraform') {
                withEnv([
                    'TF_IMAGE=hashicorp/terraform:1.8.5',
                    'TF_VARS_IMAGE_URI=${IMAGE_URI}',
                    'TF_SUBNETS=["subnet-0346e6a7e56b71359","subnet-0f98666a4bbb16c0f"]',
                    'TF_SG_ID=sg-06763288ca7ac2b1f'
                ]) {
                    sh '''
                        docker run --rm \
                          -v "$PWD":/workspace -w /workspace \
                          -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION \
                          "$TF_IMAGE" init

                        docker run --rm \
                          -v "$PWD":/workspace -w /workspace \
                          -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION \
                          "$TF_IMAGE" apply -auto-approve \
                          -var="image_uri=$TF_VARS_IMAGE_URI" \
                          -var='subnet_ids=$TF_SUBNETS' \
                          -var="security_group_id=$TF_SG_ID"
                    '''
                }
            }
        }
    }
}


        
        stage('Deploy to ECS Fargate') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                    sh """
                        aws ecs update-service \
                            --cluster ${ECS_CLUSTER} \
                            --service ${ECS_SERVICE} \
                            --force-new-deployment \
                            --region ${AWS_REGION}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build and deployment successful!"
        }
        failure {
            echo "❌ Build or deployment failed!"
        }
    }
}

pipeline {
  agent any

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
  }
}

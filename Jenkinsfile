pipeline {
  agent any
  tools {
        maven 'maven' 
    }
  stages {
    stage('Build') {
      steps {
        sh 'mvn -B -DskipTests clean package'
      }
    }

    stage('Test') {
      post {
        always {
          junit 'target/surefire-reports/*.xml'
        }

      }
      steps {
        sh 'mvn test'
      }
    }
    stage('Build Dockerfile') {
      steps {
         sh 'docker build -t java-damo:1.0 .'
	  }
    }
  }
}

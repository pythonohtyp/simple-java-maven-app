pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'echo $MAVEN_HOME'
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

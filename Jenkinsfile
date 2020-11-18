pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh '/usr/local/apache-maven-3.6.3/bin/mvn -B -DskipTests clean package'
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

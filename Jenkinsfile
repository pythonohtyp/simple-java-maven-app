pipeline {
  agent any
  tools {
        maven 'maven'
    }
  stages {
    stage('Build') {
      steps {
	sh 'echo $PATH'
        sh 'mvn -B -DskipTests clean package'
      }
    }
    stage('Dockerfile') {
      steps {
         sh 'docker build -t java-damo:1.0 .'
	  }
    }
  }
}

pipeline {
  agent any
  tools {
        maven 'maven'
	jdk 'jdk-8'
    }
  stages {
    stage('Build') {
      steps {
        sh 'mvn -B -DskipTests clean package'
      }
    }
    stage('Build Dockerfile') {
      steps {
         sh 'docker build -t java-damo:1.0 .'
	  }
    }
  }
}

pipeline {
  agent any
  tools {
        maven 'maven'
	jdk 'jdk' 
    }
  stages {
    stage('Build') {
      steps {
		sh 'echo $PATH'
        sh 'mvn -B -DskipTests clean package'
      }
    }
    stage('Create Dockerfile') {
      steps {
         sh '''cat << EOF > Dockerfile
			FROM 192.168.115.128/java/java-base:8-jdk-oralc
			WORKDIR /opt/panda
			COPY target/*.jar  .
			ENTRYPOINT ['/bin/bash','/root/run.sh']
			'''
		 sh 'cat Dockerfile'
	  }
    }
	stage('Build Images') {
	  steps {
	     sh '''
		 docker build -t 192.168.115.128/java/java-damo:${BUILD_NUMBER} .
		 docker login -u admin -p DtDream01 www.myharbor.com
		 docker push 192.168.115.128/java/java-damo:${BUILD_NUMBER}
		 '''
	  }
	}
	stage(Pull and Deploy) {
	  steps {
	     sh 'starting deploy'
	  }
	}
  }
}

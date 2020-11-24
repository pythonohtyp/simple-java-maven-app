FROM 192.168.115.128/java/java-base:8-jdk-oralc
WORKDIR /opt/panda
COPY target/*.jar  .
ENTRYPOINT ["/bin/bash","/root/run.sh"]

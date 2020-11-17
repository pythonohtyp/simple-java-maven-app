FROM jdk8:1.1
WORKDIR /opt/panda/
COPY . .
ENTRYPOINT ["/bin/bash","/usr/local/run.sh"]

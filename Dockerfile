FROM jdk8:1.0      #该镜像要在jenkins服务器上
WORKDIR /home/kmsw/
COPY . .
CMD ["/bin/bash","./jenkins/scripts/run.sh"]

#!/bin/bash
hostname=`cat /etc/hostname`
echo "127.0.0.1 $hostname" >> /etc/hosts
workdir=$(pwd)

green() {
  echo -e "\e[1;31m$*\e[0m"
}

yellow() {
  echo -e "\033[33m$*\033[0m"
}

red() {
  echo -e "\033[35m$*\033[0m"
}

normal() {
  echo $*
}

# 调整时区
rm -rf /etc/localtime
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 获取容器内存
container_max_memory() {
  local max_mem_unbounded="$(cat /sys/fs/cgroup/memory/memory.memsw.limit_in_bytes)"
  local mem_file="/sys/fs/cgroup/memory/memory.limit_in_bytes"
  if [ -r "${mem_file}" ]; then
    local max_mem="$(cat ${mem_file})"
    if [ ${max_mem} -le ${max_mem_unbounded} ]; then
      echo "${max_mem}"
    fi
  fi
}

# 计算应用可使用内存
app_default_memory() {
  if [ "x$JAVA_MAX_MEM_RATIO" = "x0" ]; then
    return
  fi

  #mb
  cmx=$(container_max_memory)
  cmx=$(echo "${cmx}" | awk '{printf "%d\n", ($1/1048576) + 0.5}')

  if [ "x$cmx" != x ]; then
    local max_mem="${cmx}"
    local ratio=${JAVA_MAX_MEM_RATIO:-50}
    local mx=$(echo "${max_mem} ${ratio}" | awk '{printf "%d\n" , ($1*$2)/100 + 0.5}')

    # 内存限制为物理内存1/4
    local phy_mx=$(cat /proc/meminfo | grep -i MemTotal | awk '{print $2}')
    phy_mx=$(echo "${phy_mx}" | awk '{printf "%d\n" , ($1*25)/102400 + 0.5}')
    if [ "$mx" -gt "$phy_mx" ]; then
      mx=$phy_mx
    fi

    echo "-Xmx${mx}m"
  fi
}

# 确定-Xmx参数
if echo "${JAVA_OPTS}" | grep -q -- "-Xmx"; then
  for arg in $JAVA_OPTS; do
    case $arg in
      -Xmx*m)
        size=$(echo "$arg" | sed -n 's#-Xmx\([0-9]\+\)m#\1#p')
      ;;
      -Xmx*g)
        size=$(echo "$arg" | sed -n 's#-Xmx\([0-9]\+\)g#\1#p' | awk '{printf "%d\n" , $1*1024}')
      ;;
    esac
  done

  #mb
  cmx=$(container_max_memory)
  cmx=$(echo "${cmx}" | awk '{printf "%d\n", ($1/1048576) + 0.5}')

  if [ $size -gt $cmx ]; then
    echo -e "\e[1;33m+++++++++++++++++++++++++++++++++++++++++++\e[0m"
    echo -e "\e[1;33mWARNING: JAVA_OPTS -Xmx配置内存大于容器内存\e[0m"
    echo -e "\e[1;33m+++++++++++++++++++++++++++++++++++++++++++\e[0m"
  fi
else
  JAVA_OPTS="$(app_default_memory) ${JAVA_OPTS}"
fi

if [ ! -z ${PACKAGE_ADDR} ]; then
  echo -e "\e[1;33mPull package from ${PACKAGE_ADDR}\e[0m"
  rm -rf /home/app.jar
  wget -q ${PACKAGE_ADDR}
  echo -e "\e[1;32mOK!\e[0m"
fi

# 在workdir及home下寻找jar
app=""
find_jar() {
  local path=${1%\/}
  local -a jars
  local idx=0
  app=""

  for jar in $(find $path -maxdepth 1 -name "*.jar"); do
    jars[$idx]=${jar}
    idx=$(($idx + 1))
  done

  if [ "${#jars[@]}" -eq "1" ]; then
    app=${jars[0]}
    return 0
  fi

  if [ "${#jars[@]}" -gt "1" ]; then
    yellow "WARNNING: NOT ONLY ONE JAR IN $path: ${jars[*]}"

    for jar in "${jars[@]}"; do
      if [ "${jar}" != "/home/app.jar" ]; then
        yellow "CHOOSE ${jar}"
        app=${jar}
        return 0
      fi
    done
  fi

  return 1
}

find_jar $workdir
if [ "x$app" == "x" ]; then
  if [ "${workdir%\/}" != "/home" ]; then
    find_jar /home
    if [ "x$app" == "x" ]; then
      red "cant find any jar file in $workdir or /home"
      exit 1
    fi
  else
    red "cant find any jar file in $workdir"
    exit 1
  fi
fi

# JAVA_OPTS支持变量传参
if [ ${_ENV_EVAL} = "true" ]; then
  JAVA_OPTS=`eval echo $JAVA_OPTS`
  APP_ARGS=`eval echo $APP_ARGS`
fi

green "+++++++++++++++++++++++++++++++++++++++++++++"
if [ ! -z ${PACKAGE_ADDR} ]; then
  echo "版本地址: ${PACKAGE_ADDR}"
fi
echo "构建时间: $(stat -c%y $app)"
echo "启动参数: $JAVA_OPTS"
echo "应用参数: $APP_ARGS"
echo "启动命令: java -jar -Djava.security.egd=file:/dev/./urandom $JAVA_OPTS $app $APP_ARGS"
green "+++++++++++++++++++++++++++++++++++++++++++++"

# 启动
java -jar -Djava.security.egd=file:/dev/./urandom $JAVA_OPTS $app $APP_ARGS

 #!/bin/sh
serverId="001"
GAME_PID=game_${serverId}.pid
JMX_IP=`ifconfig eth0 | grep "inet addr:" |awk '{print $2}' | cut -c 6-`

JVM_ARGS="-Xms1024m -Xmx1024m -Xmn512m -XX:MaxTenuringThreshold=3"
JVM_ARGS="$JVM_ARGS="" -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:ParallelGCThreads=2 -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCApplicationStoppedTime -XX:-OmitStackTraceInFastThrow -XX:+PrintTenuringDistribution" 
JVM_ARGS="$JVM_ARGS="" -Dcom.sun.management.jmxremote.port=10086"
JVM_ARGS="$JVM_ARGS="" -Dcom.sun.management.jmxremote.authenticate=false"
JVM_ARGS="$JVM_ARGS="" -Dcom.sun.management.jmxremote.ssl=false"
JVM_ARGS="$JVM_ARGS="" -Djava.rmi.server.hostname="$JMX_IP

if [ $1 == "start" ]; then
  exist=`ls -l /var/tmp/ | grep ${GAME_PID}`
  if [[ $exist != '' ]]; then
    echo "server had started"
    exit 0
  fi
  cd target/
  serverName='GameServer'
  localdir=../../gc
  today=`date +%Y-%m-%d`
  if [ ! -d $localdir ]
  then
    mkdir -p $localdir
  fi
  java -server $JVM_ARGS \
  -Xloggc:$localdir/gc_$today.log \
  -Dgame.serverId=$serverId \
  -Dfile.encoding=UTF-8 -jar $serverName.jar > /dev/null &
    echo $! > /var/tmp/${GAME_PID}
elif [ $1 == "stop" ]; then 
  #pid=`jps -lv|grep serverId=$serverId|awk '{print $1}'`
  pid=`cat /var/tmp/${GAME_PID}`
  if [ $pid > 0 ]; then   
     echo "get ready to close server"
     kill -15 $pid
     echo "server closed successfully"
  fi
elif [ $1 == "update" ]; then 
  git pull 
  mvn clean package -DskipTests 
exit 0
fi

#!/bin/sh

# service rabbitmq-server start
# service mongod start

echo ${CATALINA_HOME}

source ${CATALINA_HOME}/bin/catalina.sh run

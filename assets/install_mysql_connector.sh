#!/usr/bin/env sh
set -e

ALF_HOME=/opt/eisenvault_installations/alfresco
CONNECTOR=mysql-connector-java-5.1.43

cd /tmp
wget http://dev.mysql.com/get/Downloads/Connector-J/${CONNECTOR}.tar.gz
tar xvzf ${CONNECTOR}.tar.gz ${CONNECTOR}/${CONNECTOR}-bin.jar

mv ${CONNECTOR}/${CONNECTOR}-bin.jar ${ALF_HOME}/tomcat/lib

rm -rf /tmp/${CONNECTOR}*

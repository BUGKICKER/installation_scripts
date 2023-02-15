#!/bin/bash

DM_HOME=/dm8
INSTANCE_PATH=/dm/data
INSTALL_USER=dmdba

systemctl stop DmServiceDMSERVER
${DM_HOME}/uninstall.sh -i

if [ $DM_HOME!="/" ];then
  if [ $(whoami)=="root" ];then
    echo "switch to dbuser ${INSTALL_USER} to delete files"
    su - ${INSTALL_USER} -c "rm -r $DM_HOME"
  else
    rm -r $DM_HOME
  fi
fi

if [ $INSTANCE_PATH!="/" ];then
  if [ $(whoami)=="root" ];then
    echo "switch to dbuser ${INSTALL_USER} to delete files"
    su - ${INSTALL_USER} -c "rm -r ${INSTANCE_PATH}"
  else
    rm -r $INSTANCE_PATH
  fi
fi

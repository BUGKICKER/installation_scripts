#!/bin/bash
# This script only can be executed by root now!
# References: https://eco.dameng.com/document/dm/zh-cn/start/install-dm-linux-prepare.html
# environment
# DB version DAMENG V8
# OS version 
# kernel: Linux kylin 4.19.91-24.8.el8.ks8.11.x86_64  
# name: Kylin Linux Advanced Server release V10 (Sun)
# image url: https://distro-images.kylinos.cn:8802/web_pungi/download/share/HCrXv9VIWec4hwopd62Oukz7UsZBtL03/Kylin-Server-10-8.2-Release-Build09-20211104-X86_64.iso 
# if the image url is invalid, go to this url for clue: https://blog.csdn.net/itas109/article/details/109453945 (compatible version)

user_group=dinstall
install_user=dmdba
user_passwd=dmdba
user_home=/home/${install_user}
limit_conf=/etc/security/limits.conf
install_path=/dm8
# DAMENG DATABASE INSTANCE PATH
dinstance_path=/dm/data

# important!!!!
# wget https://download.dameng.com/eco/adapter/DM8/202302/dm8_20230105_x86_kylin10_64.zip
# download dm installation package from official site (platform zhaoxin kylin10)
# unzip dm8_20230105_x86_kylin10_64.zip
# mount -o loop /opt/dm8_20230105_x86_kylin10_64.iso /mnt
# cp /mnt/DMInstall.bin /opt/
# put dmconfig.xml to path /opt or other path then set the config_file variable 

package_path=/opt
config_file=/opt/dmconfig.xml
quiet_mode=1

# stage1: prepare for installation start
id_info=$(id ${install_user})
if [ $? -ne 0 ];then
  grep $user_group /etc/group >& /dev/null
  if [ $? -ne 0 ];then
    echo "group ${user_group} doesn't exist, create it now"
    groupadd $user_group
  fi
  echo "create user ${install_user} and set password to ${user_passwd}"
  useradd -g $user_group -m -d $user_home -s /bin/bash $install_user
  # only for user root
  echo $install_user:$user_passwd | chpasswd

# setting user resource limits
  cat >> $limit_conf <<EOF 
${install_user} hard nofile 65536
${install_user} soft nofile 65536
${install_user} hard stack 32768
${install_user} soft stack 16384
EOF

else
  user_group=$(echo $id_info | awk '{print $3}' | cut -d "(" -f 2 | cut -d ")" -f 1)
  echo "user ${install_user} exists, set user_group to be the same as the group of ${install_user} which is ${user_group}"
fi

mkdir -p $install_path $dinstance_path
chown $install_user:$user_group -R $install_path
chown $install_user:$user_group -R $dinstance_path
chmod 755 -R $install_path
chmod 755 -R $dinstance_path
# stage1 end

# stage2: install database, start
if [ $quiet_mode -eq 0 ];then
  cat <<EOF
variable quiet_mode is set to 0
start interact mode
interact mode default settings
language choose: c
key choose: n
timezone choose: y then choose 21
typical installation choose: 1
important !!!!!
installation home set to be the same as variable install_path which is $install_path
EOF
 su - $install_user -c "$package_path/DMInstall.bin -i"
else
 su - $install_user <<EOF
 cp $config_file /tmp/tmp.xml
 sed -i "s?<INSTALL_PATH></INSTALL_PATH>?<INSTALL_PATH>${install_path}</INSTALL_PATH>?g" /tmp/tmp.xml
 sed -i "s?<PATH></PATH>?<PATH>${dinstance_path}</PATH>?g" /tmp/tmp.xml
 $package_path/DMInstall.bin -q /tmp/tmp.xml
 rm /tmp/tmp.xml
EOF
fi
${install_path}/script/root/root_installer.sh
# stage2 end

# stage3: initialize database instance, start
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${install_path}/bin"
export DM_HOME=${install_path}
export PATH=${PATH}:${install_path}/bin:${install_path}/tool

cat >> ${user_home}/.bash_profile <<EOF
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${install_path}/bin"
export DM_HOME=${install_path}
export PATH=${PATH}:${install_path}/bin:${install_path}/tool
EOF

su - $install_user <<EOF
source ${user_home}/.bash_profile
${install_path}/bin/dminit path=${dinstance_path} CASE_SENSITIVE=n
EOF
${install_path}/script/root/dm_service_installer.sh -t dmserver -dm_ini ${dinstance_path}/DAMENG/dm.ini -p DMSERVER
# stage3: end

# start database service and check status
systemctl restart DmServiceDMSERVER
$install_path/bin/DmServiceDMSERVER status

